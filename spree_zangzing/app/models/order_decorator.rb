Order.class_eval do
  include PrettyUrlHelper

  attr_accessible :use_shipping_as_billing, :ship_address_id, :bill_address_id


  attr_accessor  :use_shipping_as_billing

  before_validation :clone_shipping_address, :if => "state=='ship_address'"

  after_validation :shipping_may_change, :if => 'ship_address && ship_address.zipcode_changed?'


  before_create do
      self.token = ::SecureRandom::hex(8)
  end

  def clone_shipping_address
    if @use_shipping_as_billing == '1'
      if ship_address.new_record?
        self.bill_address = Address.new( self.ship_address.attributes.except("id","user_id","updated_at", "created_at") )
      else
        self.bill_address_id = ship_address_id
      end
    else
      if use_shipping_as_billing?
        self.bill_address_id = nil
        self.bill_address    = nil
      end
    end
    true
  end

  def use_shipping_as_billing?
    (bill_address_id == ship_address_id) || bill_address.same_as?( ship_address )
  end


# order state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  Order.state_machines[:state] = StateMachine::Machine.new(Order, :initial => 'cart', :use_transactions => false) do

    event :next do
      transition :from => 'cart', :to => 'confirm',      :if => Proc.new{ |order| order.ship_address && order.payment && order.bill_address }
      transition :from => 'cart', :to => 'payment',      :if => :ship_address
      transition :from => 'cart', :to => 'ship_address'

      transition :from => 'ship_address', :to => 'confirm',      :if => Proc.new{ |order| order.payment && order.bill_address }
      transition :from => 'ship_address', :to => 'payment'

      transition :from => 'payment', :to => 'confirm'
      transition :from => 'delivery', :to => 'confirm'


      transition :from => 'confirm',       :to => 'complete'
    end

    event :cancel do
      transition :to => 'canceled', :if => :allow_cancel?
    end
    event :return do
      transition :to => 'returned', :from => 'awaiting_return'
    end
    event :resume do
      transition :to => 'resumed', :from => 'canceled', :if => :allow_resume?
    end
    event :authorize_return do
      transition :to => 'awaiting_return'
    end


    before_transition :to => 'complete' do |order|
      begin
        order.process_payments!
      rescue Spree::GatewayError
        if Spree::Config[:allow_checkout_on_gateway_error]
          true
        else
          false
        end
      end
    end

    before_transition :to => 'confirm', :do => :create_tax_charge!
    before_transition:to => 'confirm', :do => :assign_default_shipping_method
    after_transition :to => 'confirm', :do => :create_shipment!
    after_transition :to => 'complete', :do => :finalize!
    after_transition :to => 'canceled', :do => :after_cancel
  end

  # Associates the specified user with the order NO SAVE
  def associate_user(user)
    if user
      self.user =  user
      self.email = user.email
      self.ship_address_id = user.ship_address.id if user.ship_address
      self.bill_address_id = user.bill_address.id if user.bill_address

      if user.creditcard
        self.payments.build( :source => user.creditcard, :payment_method => user.creditcard.payment_method )
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


  def assign_default_shipping_method
    if shipping_method.nil?
      self.shipping_method = available_shipping_methods(:front_end).first
    end
  end


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

    shipping_may_change
    
    current_item
  end

  def contains?(variant,photo = nil)
    line_items.detect{ |line_item|
      if line_item.photo && photo
        line_item.variant_id == variant.id &&
            line_item.photo.id == photo.id
      else
        line_item.variant_id == variant.id
      end
    }
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

  def to_xml_ezporder(options = {})
    product_total = Money.new(0)
    shipping_price = Money.new(0)
    tax = Money.new(0)
    order_total = Money.new(0)

    logo_id = 1
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    options[:skip_instruct] = true
    xml.orders({ :partnerid => ZangZingConfig.config[:ezp_partner_id], :version => 1 }) {
      xml.images{
        xml.uri( {:id  => logo_id,
                 :title => 'ZangZing Logo'}, "http:www.zangzing.com/images/zz-logo.png")
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
            xml.title       ' '
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
            # totals
            variant = li.variant
            # money is expressed in cents
            product_total += Money.new(variant.price * 100) * li.quantity
            #shipping_price
            #tax
            order_total = product_total + shipping_price + tax
          end
          xml.producttotal  product_total
          xml.shippingprice shipping_price
          xml.tax           tax
          xml.ordertotal    order_total
          unless options[:shipping_calc]
            xml.shippingmethod 'FC'   #todo Ask Mau where this comes from on a real order
          end
          xml.comment       'Thank you for your order!'   # probably want to have some system setting or such where we get the comments
        }
        xml.producttotal  product_total
        xml.shippingtotal shipping_price
        xml.taxtotal      tax
        xml.total         order_total
      }
    }
  end

  def create_user
    # Override method to prevent order from creating anonymous user for guest checkin
    # In ZangZing for guest checkin the order never gets a user just an email
  end

  def require_email
    return true unless new_record? or state == 'cart' or state == 'ship_address'or state == 'payment'
  end

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

    #todo get rid of this once mau hooks up the new states
    # since the state machine transitions are called within a transaction we need
    # to ensure that any external triggers such as starting a resque job happen
    # after we have officially moved to the complete state and outside of that
    # transaction because we want to make sure the photos are prepped before
    # we give resque a chance to run.  Otherwise it could run before the photos
    # are committed to the db.  So the following line of code is now called from
    # within the checkout controller.
    #prepare_for_submit
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
    batch = UploadBatch.factory( Order.ez_prints_user_id, album.id )

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
    # maybe advance the state here and let state engine move us along
    ZZ::Async::EZPSubmitOrder.enqueue(self.id)
  end

  # submit the order to ezprints, this is a callback from a resque
  # job, if we fail, we will retry if within the limit, or ezp_submit_order_failed
  # will be called if no more retries will happen
  #
  def ezp_submit_order
    test_mode = true # for now turned off so we don't submit orders to ezprints, when mau adds flag we will base our decision on that so we can have some real orders

    ezp = EZPrints::EZPManager.new
    if test_mode
      #todo kick off loopback generation of simulated events via resque jobs
    else
      # real order placement
      ezp_reference_id = ezp.submit_order(self)
      self.ezp_reference_id = ezp_reference_id
    end
    # should advance to order submitted state as well...
    #todo advance state
    save!
  end

  def ezp_submit_order_failed
    # set the state to failed - we were unable to submit the ezp order after multiple attempts
  end

  # called when one or more of the photos was not ready in the batch processing time
  # should clean up and transition to an error state
  def photos_failed
    cleanup_photos
    # move the state to the error condition
  end

  # no longer need the photos or album for the order so clean them up
  def cleanup_photos
    album = Album.find_by_name(self.number)
    album.destroy unless album.nil?
  end

  # keeps a class level cache of the shipping costs coming from ezp.
  # this cache avoids having to call ezp more than necessary. Spree's
  # architecture recalculates the order every save which would mean an ezp call
  def shipping_costs_array
    @@shipping_costs_arrays ||= {}
    @@shipping_costs_arrays[self.number] ||= ez.shipping_costs(self)
  end

  #invalidate the shipping cost cache for the order forcing it to
  # re-fetch next time
  def shipping_may_change
    @@shipping_costs_arrays ||= {}
    @@shipping_costs_arrays.delete( self.number )
  end

  #clear the  shipping cost cache when the order has been placed
  alias shipping_costs_done shipping_may_change

  private
  def ez
     @@ezpm ||= EZPrints::EZPManager.new
  end
  
end
