Order.class_eval do
  include PrettyUrlHelper

  attr_accessible :use_shipping_as_billing, :ship_address_id, :bill_address_id, :test_mode, :printset_quantity

  attr_accessor  :use_shipping_as_billing


  has_many :log_entries, :as => :source

  before_validation :clone_shipping_address, :if => "state=='ship_address'"

  after_validation :shipping_may_change, :if => 'ship_address && ship_address.zipcode_changed?'


  before_create do
      self.token = ::SecureRandom::hex(8)
  end

  # we override the base class order number generator so we
  # can use the first character to tell us what environment
  # was used.  Will be used to let us proxy the incoming
  # EZPrints requests based on environment since they only
  # have one mapping.
  def generate_order_number
    record = true
    while record
      random = "#{ez.env_to_prefix}#{Array.new(9){rand(9)}.join}"
      record = self.class.find(:first, :conditions => ["number = ?", random])
    end
    self.number = random if self.number.blank?
    self.number
  end

  def clone_shipping_address
    if @use_shipping_as_billing == '1'
      if ship_address.new_record?
        self.bill_address = Address.new( self.ship_address.attributes.except("id","user_id","updated_at", "created_at") )
      else
        self.bill_address_id = ship_address_id
      end
    else
      #if use_shipping_as_billing?
        self.bill_address_id = nil
        self.bill_address    = nil
      #end
    end
    true
  end

  def use_shipping_as_billing?
    (bill_address_id == ship_address_id) ||(bill_address && ship_address &&  bill_address.same_as?( ship_address ))
  end

  # order state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  Order.state_machines[:state] = StateMachine::Machine.new(Order, :initial => 'cart', :use_transactions => false) do

    #This is the checkout funnel
    event :next do
      transition :from => 'cart', :to => 'confirm',         :if => Proc.new{ |order| order.ship_address && order.payment && order.bill_address }
      transition :from => 'cart', :to => 'payment',         :if => :ship_address
      transition :from => 'cart', :to => 'ship_address'

      transition :from => 'ship_address', :to => 'confirm', :if => Proc.new{ |order| order.payment && order.bill_address }
      transition :from => 'ship_address', :to => 'payment'

      transition :from => 'payment',  :to => 'confirm'
      transition :from => 'delivery', :to => 'confirm'

      transition :from => 'confirm',  :to => 'complete'
    end
    before_transition :to => 'confirm',  :do => :create_tax_charge!
    before_transition :to => 'confirm',  :do => :assign_default_shipping_method
    after_transition  :to => 'confirm',  :do => :create_shipment!
    
    before_transition :to => 'complete', :do => :process_payments!
    after_transition  :to => 'complete', :do => :finalize!

    event :prepare do
      transition :from =>'complete', :to => 'preparing'
    end

    event :submit do
      transition :from => 'preparing', :to => 'submitted'
    end
    before_transition :to => 'submitted', :do => :capture_payments
    before_transition :to => 'submitted', :do => :ezp_submit_order

    event :accept do
      transition :from => 'submitted', :to => 'accepted'
    end

    event :in_process do
      transition :from => [ 'submitted','accepted'] , :to => 'processing'
    end

    event :has_shipped do
        transition :from => ['submitted','accepted','processing'], :to => 'shipped'
    end
    after_transition :to => 'shipped', :do => :cleanup_photos

    event :cancel do
      transition :from => ['complete','preparing'], :to => 'canceled'
    end
    after_transition :to => 'canceled', :do => :send_cancel_email
    after_transition  :to => 'canceled', :do => :after_cancel
    after_transition :to => 'canceled', :do => :cleanup_photos

    event :ezp_cancel do
      transition :from => ['submitted', 'accepted','processing'], :to => 'ezp_canceled'
    end
    after_transition :to => 'ezp_canceled', :do => :send_ezpcancel_email
    after_transition  :to => 'ezp_canceled', :do => :after_cancel
    after_transition :to => 'ezp_canceled', :do => :cleanup_photos

    event :error do
      transition :to => 'failed'
    end
    after_transition :to => 'failed', :do => :send_failure_email
    after_transition :to => 'failed', :do => :cleanup_photos

    event :return do
      transition :from => 'shipped', :to => 'returned'
    end
    after_transition :to => 'returned', :do => :send_return_email

    event :resume do
      transition :to => 'resumed', :from => 'canceled', :if => :allow_resume?
    end

    after_transition ['complete','preparing',
                      'submitted','accepted',
                      'processing','shipped',
                      'canceled','ezp_canceled',
                      'failed','returned'] => any do  | order, transition|
      order.audit_trail( transition )
    end
  end

  # Associates the specified user with the order NO SAVE
  # used when a user logs in half way through the checkout process, the
  # until then guest order is associated to that user.
  def associate_user(user)
    if user
      self.user =  user
      self.email = user.email
      if user.ship_address 
        self.ship_address = user.ship_address
      else
        user.ship_address_id = nil
      end

      if user.bill_address
        self.bill_address = user.bill_address
      else
        user.bill_address_id = nil
      end

      if user.creditcard
        self.payments.build( :source => user.creditcard, :payment_method => user.creditcard.payment_method )
      else
        user.creditcard_id = nil
      end
    end
  end

  # Associates the specified user with the order and destroys any previous association with guest user if
  # necessary. SAVES ORDER
  def associate_user!(user)
    self.associate_user( user )
    # disable validations since this can cause issues when associating an incomplete address during the address step
    save(:validate => false)
  end


  #Assign the ezPrints FC shipping method by default, (the cheapest)
  def assign_default_shipping_method
    if shipping_method.nil?
      default_sm = available_shipping_methods.detect do |sm|
        sm.calculator.is_a?(Calculator::EzpShipping) &&
        sm.calculator.preferred_ezp_shipping_type == Calculator::EzpShipping::FIRST_CLASS
      end
      if default_sm
        self.shipping_method = default_sm
      else
        self.shipping_method = available_shipping_methods(:front_end).first
      end
    end
  end

  # Add an line_item to the cart
  def add_variant(variant, photo, quantity = 1)
    current_item = contains?(variant,photo)
    if current_item
      current_item.quantity += quantity
      current_item.save
    else
      logger.debug "CREATING NEW LINE ITEM"
      current_item = LineItem.new(:quantity => quantity)
      current_item.photo = photo
      current_item.variant = variant
      current_item.price   = variant.price
      self.line_items << current_item
    end

    # populate line_items attributes for additional_fields entries
    # that have populate => [:line_item]
    Variant.additional_fields.select{|f| !f[:populate].nil? && f[:populate].include?(:line_item) }.each do |field|
      value = ""

      if field[:only].nil? || field[:only].include?(:variant)
        value = variant.send(field[:name].gsub(" ", "_").downcase)
      elsif field[:only].include?(:product)
        value = variant.product.send(field[:name].gsub(" ", "_").downcase)
      end
      current_item.update_attribute(field[:name].gsub(" ", "_").downcase, value)
    end

    #notify shipping calculator cache that shipping params have changed
    #need to get shipping costs again
    shipping_may_change
    current_item
  end

  # When adding an item to a cart, if the exact variant with the same photo
  # is already there then we just increment the quantity of the existing
  # line_item
  def contains?(variant,photo = nil)
    if variant.print?
      nil
    else
      line_items.detect{ |line_item|
        if line_item.photo && photo
          line_item.variant_id == variant.id &&
              line_item.photo.id == photo.id
        else
          line_item.variant_id == variant.id
        end
      }
    end
  end

  def create_user
    # Override method to prevent order from creating anonymous user for guest checkin
    # In ZangZing for guest checkin the order never gets a user just an email
  end

  # used to decide when to validate the presence of an email address.
  def require_email
    return true unless new_record? or state == 'cart' or state == 'ship_address'or state == 'payment'
  end

  # When a user decides to checkout as guest
  def enable_guest_checkout
     self.guest = true
     self.save
  end

  def guest_checkout?
    guest
  end

  def default_payment_method
   available_payment_methods.first
  end

  # Finalizes an in progress order after checkout is complete.
  # Called after transition to complete state when payments will have been processed
  def finalize!
    update_attribute(:completed_at, Time.now)
    self.out_of_stock_items = InventoryUnit.assign_opening_inventory(self)
    # lock any optional adjustments (coupon promotions, etc.)
    adjustments.optional.each { |adjustment| adjustment.update_attribute("locked", true) }

    ZZ::Async::Email.enqueue( :order_confirmed, self.id )

    self.state_events.create({
      :previous_state => "cart",
      :next_state     => "complete",
      :name           => "order" ,
      :user_id        => (User.respond_to?(:current) && User.current.try(:id)) || self.user_id
    })
  end

  def prepare!
    # since the state machine transitions are called within a transaction we need
    # to ensure that any external triggers such as starting a resque job happen
    # after we have officially moved to the complete state and outside of that
    # transaction because we want to make sure the photos are prepped before
    # we give resque a chance to run.  Otherwise it could run before the photos
    # are committed to the db. So instead of calling prepare_for_submit as a
    # before_transition action, we have to call it here and then transition
    begin
      prepare
      prepare_for_submit
    rescue Exception => e
      self.ezp_error_message = "prepare_for_submit: #{e.message}"
      save
      error
    end
  end


  # Gaaaht meh mah moneeeeeh!
  def capture_payments
    payments.each{ |p| p.payment_source.capture(p) }
  end

  def audit_trail( transition )
    self.state_events.create({
        :previous_state => transition.from ,
        :next_state     => transition.to,
        :name           => transition.event,
        :user_id        => self.user_id
    })
    true
  end

  #used to create a ZendDesk ticket for customer support for a failed order
  def send_failure_email
    Notifier.order_support_request( self, " Had an ERROR and needs attention").deliver
  end

  #used to create a ZendDesk ticket for customer support for a returned order
  def send_return_email
    Notifier.order_support_request( self, " Was just RETURNED by the user and needs attention").deliver
  end

  #used to create a ZendDesk ticket for customer support for a canceled order
  def send_cancel_email
    Notifier.order_support_request( self, " Was just CANCELED by the customer and may need attention").deliver
  end

  #used to create a ZendDesk ticket for customer support for a canceled order by EZP
  def send_ezpcancel_email
    Notifier.order_support_request( self, " Was just CANCELED BY ezPRINTS and may need attention").deliver
  end



  # return a standard placeholder image
  # for use in shipping calc since we won't
  # have processed photos yet and we don't
  # need them at this point anyways
  def self.placeholder_image
    @@placeholder ||= {
        :id => 2,
        :title => 'placeholder',
        :url => 'http:www.zangzing.com/images/zz-logo.png'
    }
  end

  # output the exp version of the order xml
  def to_xml_ezporder(options = {})
    shipping_calc = ZZUtils.as_boolean(options[:shipping_calc])

    logo_id = 1
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    options[:skip_instruct] = true
    xml.orders({ :partnerid => ZangZingConfig.config[:ezp_partner_id], :version => 1 }) {
      xml.images{
        xml.uri( {:id  => logo_id,
                 :title => 'ZangZing Logo'}, "http://www.zangzing.com/images/zz-logo.png")
        line_items.each{ |li| li.to_xml_ezpimage( options )}
      }
      xml.ordersession{
        xml.sessionid self.number
        xml.vendor( :logoimageid => logo_id) {
          xml.name 'ZangZing'
        }
        xml.customer{
          xml.firstname   ship_address.firstname
          xml.lastname    ship_address.lastname
          xml.address1    ship_address.address1
          xml.address2    ship_address.address2
          xml.city        ship_address.city
          xml.state       ship_address.state
          xml.zip         ship_address.zipcode
          xml.countrycode ship_address.country.iso3
          xml.phone       ship_address.phone
          xml.email       email
        }
        xml.order {
          xml.orderid number
          xml.shippingaddress{
            xml.title
            xml.firstname   ship_address.firstname
            xml.lastname    ship_address.lastname
            xml.address1    ship_address.address1
            xml.address2    ship_address.address2
            xml.city        ship_address.city
            xml.state       ship_address.state
            xml.zip         ship_address.zipcode
            xml.countrycode ship_address.country.iso3
            xml.phone       ship_address.phone
            xml.email       email
          }
          line_items.each do |li|
            li.to_xml_ezporderline( options )
          end
          if shipping_calc == false
            xml.producttotal  item_total
            xml.shippingprice ship_total
            xml.tax           tax_total
            xml.ordertotal    total
            xml.shippingmethod shipping_method.calculator.preferred_ezp_shipping_type
          end
          xml.comment       'Thank you for your order!'   # probably want to have some system setting or such where we get the comments
        }
        if shipping_calc == false
          xml.producttotal  item_total
          xml.shippingtotal ship_total
          xml.taxtotal      tax_total
          xml.total         total
        end
      }
    }
  end

  # EZPrints processing stages
  #
  # When an order is completed by a user we then kick off
  # the EZPrints operations.  Initially we need to collect
  # and duplicate the assets and store them within a custom
  # album created for each order under the special 'ezprintsuser'
  # All of the albums are private albums since we don't want to
  # expose them to anyone.
  #
  # Once we have the album and the assets
  # are copied and prepped we can submit the actual order to
  # the EZPrints API.
  #
  # After submitting the order to EZPrints we monitor various status
  # transitions in the process of the order and update the state of the
  # order accordingly.  A rough outline of the stages are as follows:
  #
  # 1) Prepare order - this creates the special order album, creates
  # new photo objects that are based on the photos associated with the
  # order, we also add the new photo_id as print_photo_id to track
  # the newly created photo which is what we actually submit to EZPrints.
  #
  # Once the photo objects are created we kick off the async copy operation
  # and associate all objects with a given batch.  When that batch completes
  # we can transition to the next stage.
  #
  # 2) Submit order to EZPrints - when we have all the assets collected and
  # processed we can then submit the order to ezprints.  This will return
  # an EZPrints reference number which we associate with the order.  From
  # this point we should receive notifications from EZPrints about the status
  # of the order.  Since the connection to EZPrints may not be reliable we
  # queue the request to resque which does the actual order submit. This
  # gives us a mechanism that supports retry of the order placement.
  # If after the max time allowed we have not been able to get the order
  # submitted we stop trying and update the order state to error.
  #
  # 1.- prepare      called by after_complete in the checkout controller
  # 2.- submit       called by the prepare resque async job after the cooling period
  # 3.- accept       called by ezp controller when accept message is received
  # 3.- shipped      ezp controller calls line_items_shipped when shipped message is received
  #                  then line_items_shipped calls shipped
  # 4.- has_shipped  called by ezp controller when shipment_complete is received or when
  #                  all line items have shipped via line_items_shipped calls
  # error            called by prepare! if the preparation job cannot be completed and queued #TODO
  #                  called by ezp submit order failed
  #                  called by ezp controller if error message is received

  # fetch the id of the special ez prints user
  def self.ez_prints_user_id
    @@ez_prints_user_id ||= lambda {
      u = User.find_by_username('ezprintsuser')
      u.id
    }.call
  end

  # prepare an order for submission
  # we create the album and photos here
  # the photos still need to be processed
  # to make a copy of the s3 object and
  # the resized photo for printing needs
  # to be created.  The copy of s3, and
  # resizing are handled by a resque job.
  #
  # Once all photos have been processed
  # and are ready, the batch they are in
  # will complete and trigger the next
  # stage which is to submit the order
  # to ezprints.
  #
  def prepare_for_submit
    # create an album for this order using order number as the album name
    album = GroupAlbum.create(:user_id => Order.ez_prints_user_id, :privacy => 'password', :name => self.number, :for_print => true)

    # create a new upload batch to group them all together
    batch = UploadBatch.factory( Order.ez_prints_user_id, album.id, true )

    # now set up the photos we need to copy and track them in the line items
    line_items.each do |li|
      photo = li.photo
      print_photo = Photo.copy_photo(photo, :user_id => Order.ez_prints_user_id, :album_id => album.id,
                      :upload_batch_id => batch.id, :for_print => true)
      li.print_photo = print_photo
      li.save!
    end

    # close out this batch since no new photos will be added to it
    batch.close_immediate
  end

  # called when all photos have been successfully processed
  # everything is ready to go, so time to submit the order to ezprints
  def photos_processed
    # since this is called via batch completion, no point in moving on if we have already been canceled or have failed
    return if canceled? || failed?

    # start the cooling off timer which gives us a window in which we can cancel
    # before we submit to ezprints - at the end of the window resque calls order.submit
    # which in turn calls ezp_submit_order, after this point we have no control
    # over the ezprints order process so cannot cancel from our end
    ZZ::Async::EZPSubmitOrder.enqueue_in(ZangZingConfig.config[:order_cancel_window], self.id)
  end

  # submit the order to ezprints, this is a callback from a resque
  # job, if we fail, we will retry if within the limit, or ezp_submit_order_failed
  # will be called if no more retries will happen
  #
  def ezp_submit_order
    # the test_mode flag tells us if we should submit "real" orders (when false) to ezprints or simulate the order flow internally (when true)
    if self.test_mode
      # kick off loopback mode for order simulation - the EZPSimulator will
      # call back to simulate the order notification flow as if it was coming from EZPrints
      ZZ::Async::EZPSimulator.simulate_order(self)
    else
      # real order placement
      self.ezp_reference_id = ez.submit_order(self)
      save!
    end
  end

  def ezp_submit_order_failed
    # set the state to failed - we were unable to submit the ezp order after multiple attempts
    error
  end

  # called when one or more of the photos was not ready in the batch processing time
  # should clean up and transition to an error state
  def photos_failed
    cleanup_photos
    error
  end

  # no longer need the photos or album for the order so clean them up
  def cleanup_photos
    user = User.find(Order.ez_prints_user_id)
    album = user.albums.find_by_name(self.number)
    # this needs to run as a delayed job because Rails does not
    # properly notify the full chain of dependent objects on after commit for delete
    # so we don't get to clean up properly - the issue appears to be when
    # destroy is called within a transaction, so we run it as a delayed
    # job where it runs outside of a transaction
    ZZ::Async::DelayedUtils.delayed_destroy_album(album) unless album.nil?
  end

  # ezp Shipping calculator integration
  # keeps a class level cache of the shipping costs coming from ezp.
  # this cache avoids having to call ezp more than necessary. Spree's
  # architecture recalculates the order every save which would mean an ezp call
  def shipping_costs_array
    @@shipping_costs_arrays ||= {}
    @@shipping_costs_arrays[self.number] ||= ez.shipping_costs(self)
  end

  # ezp Shipping calculator integration
  #invalidate the shipping cost cache for the order forcing it to
  # re-fetch next time
  def shipping_may_change
    @@shipping_costs_arrays ||= {}
    @@shipping_costs_arrays.delete( self.number )
  end

  # ezp Shipping calculator integration
  #clear the  shipping cost cache when the order has been placed
  alias shipping_costs_done shipping_may_change


  # When receiving an ezp shippment notice,
  # mark the line items as shipped and add a carrier::tracking number combo
  # Orders have a shipment ready by default,
  # The first time this method is called, the ready shipment is used and marked as shipped
  # Subsequent calls will create a new shipment each
  #
  def line_items_shipped( tracking_number, carrier, line_item_id_array )
    # Get the first ready shipment from the shipment list,
    # if no ready shipment, create a new one
    return if line_item_id_array.blank?
    line_item_id_array.uniq!    # get rid of any duplicates

    # make sure we only include line items that have not already been associated with a shipment
    filtered_line_item_ids = []
    self.line_items.each do |line_item|
      filtered_line_item_ids << line_item.id if line_item.shipment_id.nil? && line_item_id_array.include?(line_item.id)
    end
    return if filtered_line_item_ids.blank?

    shp = shipments.detect{|shp| shp.ready? || shp.pending? }
    if !shp
      shp = self.shipments.create( :shipping_method => ShippingMethod.find_by_name!('ezPrintsPartialShipment'),
                                    :address => self.ship_address)
      shp.reload
    end

    # Store carrier::tracking number in the shipment tracking field
    if carrier.present? && tracking_number.present?
      shp.tracking        = "#{carrier}::#{tracking_number}"
    else
      shp.tracking        = "#{carrier}#{tracking_number}"
    end
    shp.line_item_ids   = filtered_line_item_ids
    shp.shipped_at = Time.now()
    old_state = self.state
    shp.ship

    # audit trail
    self.state_events.create({
        :previous_state => old_state,
        :next_state     => self.state,
        :name           => "ezp shipment" ,
        :user_id        => (User.respond_to?(:current) && User.current && User.current.id) || self.user_id
    })
  end

  # Updates the +shipment_state+ attribute according to the following logic:
  #
  # shipped   when all Line items are shipped?
  # partial   when at least one line_item is "shipped?" and there is another line_item not shipped  
  # ready     when all Shipments are in the "ready" state
  # pending   when all Shipments are in the "pending" state
  #
  # The +shipment_state+ value helps with reporting, etc. since it provides a quick and easy way to locate Orders needing attention.
  def update_shipment_state
    self.shipment_state =
    case line_items.count
    when 0
      nil
    when line_items.shipped.count
      "shipped"
    when line_items.pending.count
      "pending"
    when line_items.ready.count
      "ready"
    else
      "partial"
    end

    if old_shipment_state = self.changed_attributes["shipment_state"]
      #if shipment_state changed
      self.state_events.create({
        :previous_state => old_shipment_state,
        :next_state     => self.shipment_state,
        :name           => "shipment" ,
        :user_id        => (User.respond_to?(:current) && User.current && User.current.id) || self.user_id
      })
      self.has_shipped if shipment_state == "shipped"
    end

  end

  def printset_quantity=( qty_hash )
    qty_hash.each_pair do | variant_id, qty|
      line_items.find_all_by_variant_id( variant_id ).each do |li|
        li.quantity = qty
        li.save
      end
    end
  end

  def cart_count
    line_items.prints.group_by_variant.count.length + line_items.not_prints.count.length
  end


  def billing_zipcode
     bill_address.try(:zipcode)
   end


  private

  def ez
     @@ezpm ||= EZPrints::EZPManager.new
  end
  
end
