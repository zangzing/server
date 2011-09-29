LineItem.class_eval do
  attr_accessible :photo_id, :crop_instructions, :back_message, :print_photo

  belongs_to :photo
  belongs_to :print_photo, :class_name => "Photo"
  belongs_to :shipment


  before_save :shipping_may_change, :if => :quantity_changed?

  scope :shipped, joins(:shipment).where("line_items.shipment_id IS NOT NULL AND line_items.shipment_id = shipments.id AND shipments.state = 'shipped'")
  scope :ready,   joins(:shipment).where("line_items.shipment_id IS NOT NULL AND line_items.shipment_id = shipments.id AND shipments.state = 'ready'")
  scope :pending, joins(:shipment).where("line_items.shipment_id IS NULL OR line_items.shipment_id = shipments.id AND shipments.state = 'pending'")



  def shipping_may_change
    order.shipping_may_change
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
      photo_title = back_message || print_photo.caption || ''
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

end
