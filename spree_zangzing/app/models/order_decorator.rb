Order.class_eval do
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

end
