unless defined? LineItem::PRINTS_PRODUCT_ID
  LineItem::PRINTS_PRODUCT_ID = 941187648  # Prints product id
  LineItem::NO_FRAME_VALUE_ID = 28         # No Frame (for prints-frame-and-mate option_type )
  LineItem::FRAMED_VALUE_ID   = 53         # Framed (for prints-finish option-type )
end


LineItem.class_eval do
  attr_accessible :photo_id, :crop_instructions, :back_message, :print_photo, :hidden


  belongs_to :photo
  belongs_to :print_photo, :class_name => "Photo"
  belongs_to :shipment


  before_save :shipping_may_change, :if => :quantity_changed?

 
  scope :shipped, joins(:shipment).where("line_items.shipment_id IS NOT NULL AND line_items.shipment_id = shipments.id AND shipments.state = 'shipped'")
  scope :ready,   joins(:shipment).where("line_items.shipment_id IS NOT NULL AND line_items.shipment_id = shipments.id AND shipments.state = 'ready'")
  scope :pending, where("line_items.shipment_id IS NULL")


  # Line items for prints that do not have a frame (checking the frame_matte== 'No Frame' option_type value)
  scope :prints, joins(:variant)\
              .joins("join option_values_variants on option_values_variants.variant_id = variants.id")\
              .where("line_items.hidden = 0 AND variants.product_id = ? AND option_values_variants.option_value_id = ?", LineItem::PRINTS_PRODUCT_ID, LineItem::NO_FRAME_VALUE_ID)


  # Line items for not prints or prints that have a frame (checking the prints_finish == framed option_type value)
  scope :not_prints, joins(:variant)\
              .joins("join option_values_variants on option_values_variants.variant_id = variants.id")\
              .where("line_items.hidden = 0 AND variants.product_id <> ? || (  variants.product_id = ? AND option_values_variants.option_value_id = ?)",LineItem::PRINTS_PRODUCT_ID,LineItem::PRINTS_PRODUCT_ID, LineItem::FRAMED_VALUE_ID)\
              .group('line_items.id').order('line_items.created_at DESC')

  scope :prints_by_variant, select('line_items.*, MAX( line_items.created_at) as created_at')\
                .joins(:variant)\
                .joins("join option_values_variants on option_values_variants.variant_id = variants.id")\
                .where("line_items.hidden = 0 AND variants.product_id = ? AND option_values_variants.option_value_id = ?", LineItem::PRINTS_PRODUCT_ID, LineItem::NO_FRAME_VALUE_ID)\
                .group('variants.id')\
                .order(' created_at ASC')

  scope :group_by_variant, joins(:variant).group('variants.id').order('line_items.created_at DESC')

  scope :visible_by_variant, lambda { |variant| where('line_items.variant_id = ? AND line_items.hidden = 0', variant.id).order('created_at DESC') }

  # used to determine max safe statement size for
  # a bulk insert on this connection
  def self.max_insert_size
    @@safe_max_size ||= RawDB.safe_max_size(LineItem.connection)
  end

  # fast low level database operations

  # perform a bulk insert of shipment ids
  # takes rows in the form
  # [ [id, shipment_id], ... ]
  # does an update on all of the rows specified in
  # a minimal number of queries
  def self.fast_update_shipment_ids(rows)
    db = LineItem.connection
    base_cmd = "INSERT INTO #{LineItem.quoted_table_name}(id, shipment_id) VALUES "
    end_cmd = " ON DUPLICATE KEY UPDATE shipment_id = VALUES(shipment_id)"
    RawDB.fast_insert(db, LineItem.max_insert_size, rows, base_cmd, end_cmd)
  end

  # perform a bulk insert of shipment ids
  # takes rows in the form
  # [ [id, print_photo_id], ... ]
  # does an update on all of the rows specified in
  # a minimal number of queries
  def self.fast_update_print_photo_ids(rows)
    db = LineItem.connection
    base_cmd = "INSERT INTO #{LineItem.quoted_table_name}(id, print_photo_id) VALUES "
    end_cmd = " ON DUPLICATE KEY UPDATE print_photo_id = VALUES(print_photo_id)"
    RawDB.fast_insert(db, LineItem.max_insert_size, rows, base_cmd, end_cmd)
  end


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
      raise ArgumentError.new("Missing print photo for line item id: #{self.id}, order id: #{self.order_id}") if print_photo.nil?
      photo_id = print_photo.id
      photo_title = nil_if_empty(back_message) || nil_if_empty(print_photo.caption) || 'www.zangzing.com'
      photo_url = print_photo.full_size_url
    end
    xml.uri( {:id  => photo_id,
             :title => photo_title}, photo_url)
  end

  def to_xml_ezporderline(options = {})
   options[:indent] ||= 2
   xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
   xml.instruct! unless options[:skip_instruct]
   options[:skip_instruct] = true
   if options[:shipping_calc]
     placeholder = Order.placeholder_image
     photo_id = placeholder[:id]
   else
     raise ArgumentError.new("Missing print photo for line item id: #{self.id}, order id: #{self.order_id}") if print_photo.nil?
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
