Order.class_eval do
  attr_accessible :use_shipping_as_billing, :ship_address_id, :bill_address_id

  before_validation :clone_shipping_address, :if => "@use_shipping_as_billing"
  attr_accessor :use_shipping_as_billing

  def clone_shipping_address
    self.bill_address_id = ship_address_id
    true
  end

  before_create do
    self.token = ::SecureRandom::hex(8)
  end



# order state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  Order.state_machines[:state] = StateMachine::Machine.new(Order, :initial => 'cart') do

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

    after_transition :to => 'payment', :do => :create_tax_charge!
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


  def add_variant(variant, photo_data, quantity = 1)
    current_item = contains?(variant,photo_data)
    if current_item
      current_item.quantity += quantity
      current_item.save
    else
      logger.debug "CREATING NEW LINE ITEM"
      current_item = LineItem.new(:quantity => quantity)
      current_item.photo_data = photo_data
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

    current_item
  end

  def contains?(variant,photo_data = nil)
    line_items.detect{ |line_item|
      if line_item.photo_data && photo_data
        line_item.variant_id == variant.id &&
            line_item.photo_data.source_url == photo_data.source_url
      else
        line_item.variant_id == variant.id
      end
    }
  end

  def to_xml_ezporder(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.orders{
      xml.images{
        line_items.each{ |li| li.to_xml_ezpimage( :builder => xml, :skip_instruct => true )}
      }
      xml.ordersession{
        xml.sessionid self.number
        xml.vendor( :logoimageid => 3) {
          xml.name 'ZangZing'
        }
        #xml.customer{}
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
          line_items.each{ |li| li.to_xml_ezporderline( :builder => xml, :skip_instruct => true )}
          xml.shippingmethod 'FC'
        }
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
end
