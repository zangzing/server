LineItem.class_eval do
  attr_accessible :photo_id, :crop_instructions, :back_message

  belongs_to :photo

  def to_xml_ezpimage( options = {})
    return unless photo
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.uri( {:id  => photo.id,
             :title => photo.caption || "No caption"}, photo.original_url)
  end

  def to_xml_ezporderline(options = {})
   return unless photo
   options[:indent] ||= 2
   xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
   xml.instruct! unless options[:skip_instruct]
   xml.orderline( :productid => variant.sku,
                  :imageid   => photo.id){
     xml.description
     xml.productprice variant.price
     xml.quantity quantity
     xml.position crop_instructions
   }
 end

end
