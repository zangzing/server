LineItem.class_eval do
  attr_accessible :photo_id, :crop_instructions, :back_message, :print_photo


  belongs_to :photo
  belongs_to :print_photo, :class_name => "Photo"
  belongs_to :shipment


  before_save :shipping_may_change, :if => :quantity_changed?

  scope :shipped, joins(:shipment).where("line_items.shipment_id IS NOT NULL AND line_items.shipment_id = shipments.id AND shipments.state = 'shipped'")
  scope :ready,   joins(:shipment).where("line_items.shipment_id IS NOT NULL AND line_items.shipment_id = shipments.id AND shipments.state = 'ready'")
  scope :pending, where("line_items.shipment_id IS NULL")

  scope :prints, joins(:product).joins(:variant).where("products.name = 'Prints' AND variants.price < ? ",Spree::Config[:printset_threshold]).order('variants.price ASC')
  scope :group_by_variant, joins(:variant).group('variants.id').order('variants.price ASC')
  scope :not_prints, joins(:product).joins(:variant).where("products.name != 'Prints' || variants.price >=?",Spree::Config[:printset_threshold])

  
  def shipping_may_change
    order.shipping_may_change
  end

  # return nil if nil or empty, otherwise
  # the passed value is returned
  #
  # simplifies assignments with multiple ORs
  #
  def nil_if_empty(value)
    value.nil? || value.empty? ? nil : value
  end

  def to_xml_ezpimage( options = {})
    return unless photo
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    options[:skip_instruct] = true
    if options[:shipping_calc]
      placeholder = Order.placeholder_image
      photo_id = placeholder[:id]
      photo_title = placeholder[:title]
      photo_url = placeholder[:url]
    else
      photo_id = print_photo.id
      photo_title = nil_if_empty(back_message) || nil_if_empty(print_photo.caption) || 'www.zangzing.com'
      photo_url = print_photo.full_size_url
    end
    xml.uri( {:id  => photo_id,
             :title => photo_title}, photo_url)
  end

  def to_xml_ezporderline(options = {})
   return unless photo
   options[:indent] ||= 2
   xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
   xml.instruct! unless options[:skip_instruct]
   options[:skip_instruct] = true
   if options[:shipping_calc]
     placeholder = Order.placeholder_image
     photo_id = placeholder[:id]
   else
     photo_id = print_photo.id
   end
   xml.orderline( :productid => variant.sku,
                  :imageid   => photo_id){
     xml.affiliatekey self.id
     #xml.description
     xml.quantity quantity
     xml.position crop_instructions.nil? ? 'Crop' : crop_instructions
   }
 end

  def shipped?
    if shipment && shipment.shipped?
      return true
    end
    false
  end

  def option_values
    OptionValue.in_line_item( self )
  end

  def print?
    variant.print?
  end
end
