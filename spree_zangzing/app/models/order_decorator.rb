unless defined? Order::MKTG_INSERT_VARIANT_ID
  Order::MKTG_INSERT_VARIANT_ID  = 791384334
  Order::MKTG_INSERT_USER_NAME   = 'zzmarketing'
  Order::MKTG_INSERT_ALBUM_NAME  = 'Marketing Prints'
end


Order.class_eval do
  include PrettyUrlHelper

  attr_accessible :use_shipping_as_billing, :ship_address_id, :bill_address_id, :test_mode, :printset_quantity

  attr_accessor  :use_shipping_as_billing


  has_many :log_entries, :as => :source

  before_validation :clone_shipping_address, :if => "state=='ship_address'"

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
    before_transition :to => 'confirm',  :do => :add_marketing_insert
    before_transition :to => 'confirm',  :do => :create_tax_charge!
    before_transition :to => 'confirm',  :do => :assign_default_shipping_method
    after_transition  :to => 'confirm',  :do => :create_default_shipment!
    
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

  # to allow control over the updating of order state we provide
  # thread local support to prevent/allow order update from happening
  # We need this because when we want to make changes in bulk, i.e. inserting
  # multiple line items each one kicks off a huge amount of work but we
  # really only need the order state to be updated at the very end
  # so we've added this thread local flag along with the appropriate
  # checks in the update! method.  Technically we don't really need to
  # use thread local since we know we are always single threaded but
  # this would be needed for future support of multi threading so it
  # makes sense to do it now.
  #
  # By the way, we can't simply set the state on an instance of order because
  # there are various places where spree loads a new order object that represents
  # the same order we started with but is a seperate instance
  #
  # The way this works is that we track the root order, this will be available
  # at any point so that we can grab it and check any flags that might
  # have been set on it from any point, even if some intermediate stage
  # loaded the equivalent order, we allways call root_order to fetch
  # the outermost order as set by the controllers.
  #
  # the thread_options methods operate on a hash that is passed
  # to them - you extract the hash and query the info you care about
  def self.thread_options
    options = Thread.current[:order_thread_options] || {}
  end

  # Call the appropriate spree code encapsulating
  # the thread local options
  # this ensures that we always exit with the thread
  # local options restored on exit
  def self.call_with_thread_options(options, &block)
    begin
      prev_options = Thread.current[:order_thread_options]
      Thread.current[:order_thread_options] = options
      block.call()
    rescue Exception => ex
      raise ex
    ensure
      Thread.current[:order_thread_options] = prev_options
    end
  end


  # get the original update! method before we redefine it
  @@original_update_bang ||= instance_method('update!')

  # control whether the update happens or not based
  # on our options
  def update!
    options = Order.thread_options
    unless options[:prevent_update]
      # let the original update! happen
      self.line_items.includes(:variant => {:product => :tax_category})

      @@original_update_bang.bind(self).call
    end
  end

  # create a default shipment if we don't already have one
  # this forces the shipping calc to on even if the options
  # have it set to off
  def create_default_shipment!
    Order.call_with_thread_options({}) do
      create_shipment!
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

  # clear all of our cached data
  def self.clear_caches
    @@first_class = nil
  end

  # cache this - only downside is that if we want
  # to change markup it will require a server restart
  def first_class_shipping_method
    @@first_class ||= available_shipping_methods.detect do |sm|
        sm.calculator.is_a?(Calculator::EzpShipping) &&
        sm.calculator.preferred_ezp_shipping_type == Calculator::EzpShipping::FIRST_CLASS
    end
  end

  #Assign the ezPrints FC shipping method by default, (the cheapest)
  def assign_default_shipping_method
    if shipping_method.nil?
      default_sm = first_class_shipping_method
      if default_sm
        self.shipping_method = default_sm
      else
        self.shipping_method = available_shipping_methods(:front_end).first
      end
    end
  end

  # does a blazing fast batch insert, bypasses
  # all spree logic so make sure you reload
  # order after calling
  # [ [line_item_id, order_id, variant_id, quantity_change, price, created_at, updated_at, photo_id], ... ]
  def fast_add_photos(variant, photo_ids, quantity = 1)
    variant_id = variant.id
    now = DateTime.now
    rows = []

    # Override the quantity if we already have for_print items under this variant
    # to ensure they all have a consistent quantity. Otherwise you can end up with
    # items of different counts even though the UI shows them as having the same grouped count.
    if variant.print?
      max = LineItem.maximum(:quantity, :conditions => {:order_id => self.id, :variant_id => variant_id})
      quantity = max unless max.nil?
    end

    # build up the low level row data for fast insert
    photo_ids.each do |photo_id|
      row = [nil, self.id, variant_id, quantity, variant.price, now, now, photo_id]
      rows << row
    end
    # modifies rows in place
    prepare_for_fast_add(variant, rows)
    # update the db
    LineItem.fast_update_items(rows)
  end

  # populate the line_item_id of each matching
  # photo and/or variant
  # modifies rows in place
  # takes rows in the form
  # [ [line_item_id, order_id, variant_id, quantity_change, price, created_at, updated_at, photo_id], ... ]
  # this approach of using array offsets is fragile but very fast
  def prepare_for_fast_add(variant, rows)
    if variant.print? == false
      # make a hash containing variant_id+photo_id to li
      # this lets us quickly populate the rows with matches
      vp_to_li = {}
      line_items.each do |item|
        item_id = item.id
        variant_id = item.variant_id
        photo_id = item.photo_id
        key = make_key(variant_id, photo_id)
        vp_to_li[key] = item_id
      end
      # modify rows in place
      i = 0
      while i < rows.length
        row = rows[i]
        photo_id = row[7]
        variant_id = row[2]
        key = make_key(variant_id, photo_id)
        # try variant+photo match
        line_item_id = vp_to_li[key]
        if line_item_id.nil?
          # try variant only match
          key = make_key(variant_id, nil)
          line_item_id = vp_to_li[key]
        end
        if line_item_id
          # line item changed
          row[0] = line_item_id
          rows[i] = row
        end
        i += 1
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

    #notify shipping calculator cache that shipping params have changed
    #need to get shipping costs again
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

  # make a multi part key
  def make_key(*args)
    key = ''
    args.each do |arg|
      key << "#{arg}:"
    end
    key
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
   available_payment_methods.last
  end

  # Finalizes an in progress order after checkout is complete.
  # Called after transition to complete state when payments will have been processed
  def finalize!
    update_attribute(:completed_at, Time.now)
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
      queue_prepare_for_submit
    rescue Exception => e
      self.ezp_error_message = "prepare_for_submit: #{e.message}"
      save
      error
    end
  end

  def add_marketing_insert
    index_print_product_ids = Product.taxons_name_eq('index_print').map{|p| p.id }
    variant = Variant.find_by_id( Order::MKTG_INSERT_VARIANT_ID )
    if visible_line_items.detect { |li| index_print_product_ids.include? li.variant.product_id }
      # The cart contains prints, add a new marketing insert or
      # make sure the existing marketing insert's quantity is one
      if existing_insert = line_items.find_by_hidden_and_variant_id(true, variant.id)
        existing_insert.quantity = 1
        existing_insert.save
      else
        photo = ez.marketing_insert( Order::MKTG_INSERT_USER_NAME, Order::MKTG_INSERT_ALBUM_NAME)
        if variant && photo
          li = LineItem.new()
          li.quantity = 1
          li.price    = 0.0
          li.variant  = variant
          li.photo    = photo
          li.hidden   = true
          self.line_items << li
        else
          Rails.logger.error( "MARKETING INSERT ERROR: Variant with id=#{Order::MKTG_INSERT_VARIANT_ID} not found") if variant.nil?
          Rails.logger.error( "MARKETING INSERT ERROR: No marketing insert image found. Looking in user=#{Order::MKTG_INSERT_USER_NAME} album=#{Order::MKTG_INSERT_ALBUM_NAME}") if photo.nil?
        end
      end
    else
      # The cart does not contains prints, make sure there is no marketing print
      if existing_insert = line_items.find_by_hidden_and_variant_id(true, variant.id)
        existing_insert.destroy
      end
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

    thank_you = "Thank you for shopping at ZangZing. We hope you enjoy your purchase.

We provide a 100% satisfaction guarantee. If you have any questions regarding your order or have any suggestions, including future products, please email us at help@zangzing.com.

Have a wonderful time sharing photos! And, we hope you think of us and visit www.zangzing.com."

    logo_id = 1
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    options[:skip_instruct] = true
    # fast load line items and associated print photos
    line_items = LineItem.includes(:print_photo, :variant).find_all_by_order_id(self.id)
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
          xml.comment       thank_you   # probably want to have some system setting or such where we get the comments
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

  # validate that all of the photos associated with the
  # line items exist - will return true if they all exist and are ready,
  # false otherwise
  def all_photos_valid?
    # bulk load all the line items and photos
    all_valid = true
    lines = LineItem.includes(:photo).find_all_by_order_id(self.id)
    lines.each do |line|
      photo = line.photo
      if photo.nil? || !photo.ready?
        line.destroy
        all_valid = false
      end
    end
    self.reload unless all_valid
    all_valid
  end

  # queue up the job to do the prepare to take this
  # out of the mainline app server since it can
  # be run as a background job
  def queue_prepare_for_submit
    ZZ::Async::EZPSubmitOrder.enqueue(self.id, :prepare_for_submit, :timeout_multiplier => 3.0)
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
    # first preload everything we need in three queries (line_items, photos, photo_infos)
    lines = LineItem.includes(:photo => :photo_info).find_all_by_order_id(self.id)
    originals = []
    line_rows = []
    lines.each do |li|
      photo = li.photo
      options = { :user_id => Order.ez_prints_user_id, :album_id => album.id,
                  :upload_batch => batch, :for_print => true }
      originals << { :photo => photo, :options => options }
      line_rows << li.id  # ensure the ordering matches the copied photos
    end

    # copy the originals
    print_photos = Photo.copy_photos(originals)

    # Now update line items to use new copies for print_photo id.
    # The lists are in sync so item 0 of lines gets photos 0, etc...
    i = 0
    rows = []
    line_rows.each do |line_item_id|
      # build data for fast insert into line_items
      row = [ line_item_id, print_photos[i].id ]
      rows << row
      i += 1
    end

    # use a direct update to avoid any callbacks - saving a changed line item is
    # unbelievably inefficient - the batch insert/update below on the other hand is
    # incredibly fast
    LineItem.fast_update_print_photo_ids(rows)

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
    cancel_window = ZangZingConfig.fast_ezp_simulator? ? 1 : ZangZingConfig.config[:order_cancel_window]
    ZZ::Async::EZPSubmitOrder.enqueue_in(cancel_window, self.id, :ezp_submit_order)
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

  # get the shipping costs, if no_calc set return empty cost without going to network
  def shipping_costs
    # only compute shipping costs once per calling context
    options = Order.thread_options
    costs = options[:shipping_costs]
    if costs.nil?
      costs = ez.shipping_costs(self)
      options[:shipping_costs] = costs
    end
    costs
  end


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
    filtered_line_items = self.line_items.select{ |li| li.shipment_id.nil? && line_item_id_array.include?(li.id)}
    return if filtered_line_items.blank?

    shp = shipments.detect{|shp| shp.ready? || shp.pending? }
    if !shp
      shp = self.shipments.create( :shipping_method => ShippingMethod.find_by_name!('ezPrintsPartialShipment'),
                                    :address => self.ship_address)
      shp.reload
    end

    # if the original shipping method was first class, we can't rely on the
    # tracking number to be meaningful according to EzPrints so ditch
    # the tracking number and pretend it is a USPS order even though
    # they might have sent it through some other bizarre means
    if first_class_shipping_method && self.shipping_method_id == first_class_shipping_method.id
      carrier = 'USPS'
      tracking_number = ''
    end
    # Store carrier::tracking number in the shipment tracking field
    if carrier.present? && tracking_number.present?
      # FILTER CARRIER, ezPrints feeds tracking numbers like UPS 12345678
      # which are NOT United Parcel Service tracking numbers but USPS so make carrier USPS unless
      # the tracking number is indeed a UPS number
      if carrier == 'UPS'
        unless /\b(1Z ?[0-9A-Z]{3} ?[0-9A-Z]{3} ?[0-9A-Z]{2} ?[0-9A-Z]{4} ?[0-9A-Z]{3} ?[0-9A-Z]|[\dT]\d\d\d ?\d\d\d\d ?\d\d\d)\b/ =~ tracking_number
          carrier = 'USPS'
        end
      end
      shp.tracking        = "#{carrier}::#{tracking_number}"
    else
      shp.tracking        = "#{carrier}#{tracking_number}"
    end
#    shp.line_items   = filtered_line_items
    # use direct insert for performance this is many many times faster than above line
    rows = filtered_line_items.map {|item| [item.id, shp.id]}
    LineItem.fast_update_shipment_ids(rows)

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
    shp
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
      qty = qty.to_i
      # change the line item counts
      LineItem.update_all("quantity = #{LineItem.connection.quote(qty)}", :order_id => self.id, :variant_id => variant_id)
    end
  end

  def delete_line_items_at_zero
    # change the line item counts
    LineItem.delete_all( [ "quantity <= 0 AND order_id = ?", self.id] )
    self.reload
  end

  def cart_count
    line_items.prints.group_by_variant.count.length + line_items.not_prints.count.length
  end


  def billing_zipcode
     bill_address.try(:zipcode)
  end

  def visible_line_items
    grouped_id_sql = line_items.grouped_ids_by_variant.to_sql
    visible_line_items = line_items.find_by_sql("SELECT line_items.* FROM line_items INNER JOIN (#{grouped_id_sql}) print_sets on print_sets.id = line_items.id")
    visible_line_items.concat( line_items.not_prints.includes(:photo, :variant => [:product, :images]) )
    visible_line_items.sort!{ |a,b| b.id <=> a.id }
    visible_line_items
  end


  private

  def ez
     @@ezpm ||= EZPrints::EZPManager.new
  end
  
end
