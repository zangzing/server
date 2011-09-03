module EZPrints
  # takes an order in the shipping calc format from the order class
  # and transmits that to EZprints returning a hash with the shipping
  # options and prices
  class ShippingCalculator
    def shipping_costs(order)
      order_xml = order.to_xml_ezporder
      puts order_xml.to_s

      # now send the request
      #todo get url from config
      #todo code is hacked to use the order code while we try to figure out why the are returning errors....
#      uri = URI.parse('http://www.ezprints.com/ezpartners/shippingcalculator/xmlshipcalc.asp')
      uri = URI.parse(URI.escape("http://order.ezprints.com/PostXmlOrder.axd?PartnerNumber=#{ZangZingConfig.config[:ezp_partner_id]}&PartnerReference=#{order.number}"))

      http = Net::HTTP.new(uri.host, uri.port)
      query_part = uri.query.nil? ? '' : "?#{uri.query}"
      path_with_query = uri.path + query_part
      response, body = http.post(path_with_query, order_xml.to_s, {'Content-Type'=>'text/xml;charset=utf-8'})
      puts body
      puts "done"
    end
  end
end
