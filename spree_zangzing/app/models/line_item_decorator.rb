LineItem.class_eval do
   attr_accessible :photo_data_attributes

  has_one :photo_data, :class_name => "LineItemPhotoData"

  accepts_nested_attributes_for :photo_data, :allow_destroy => true


  def to_xml_ezpimage( options = {})
    return unless photo_data
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.uri( {:id  => photo_data.id, #USE ZZ PHOTO ID :TODO
             :title => 'A Photo'}, photo_data.source_url)
  end

  def to_xml_ezporderline(options = {})
   return unless photo_data
   options[:indent] ||= 2
   xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
   xml.instruct! unless options[:skip_instruct]
   xml.orderline( :productid => variant.sku,
                  :imageid   => photo_data.id){ #USE ZZ PHOTO ID :TODO
     xml.description
     xml.productprice variant.price
     xml.quantity quantity
     xml.position photo_data.crop_instructions
   }
 end

end
