module EZPrints
  class EZPManager

    def header_options
#      @@header_options ||= {'Content-Type' => 'text/xml;charset=utf-8'}
      @@header_options ||= {'Content-Type' => 'text/xml'}
    end

    # takes an order in the shipping calc format from the order class
    # and transmits that to EZprints returning a hash with the shipping
    # options and prices
    # returns an array of the shipping options in the form:
    # [
    # {
    #   :type => FC, PM, SD, ON, etc
    #   :price => cost of shipping
    #   :shippingMethod => USFC, etc
    #   :description => Description of shipping method
    # }
    # ...
    # ]
    #
    def shipping_costs(order)
      order_xml = order.to_xml_ezporder
      result_xml = submit_http_request("http://www.ezprints.com/ezpartners/shippingcalculator/xmlshipcalc.asp",
          order_xml.to_s, header_options)
      err = result_xml.at_xpath("//shippingOptions/error")
      if err
        desc = err['description'] || "Error description not returned."
        err_num = err['number'] || -1
        raise "Error returned from EZPrints shipping calculator: #{err_num}. #{desc}"
      else
        # put the result into an array of hashes
        path = result_xml.at_xpath("//shippingOptions/order")
        hash = HashConverter.from_xml(path, false, true)
        ship_options = hash[:order][:option]
        if ship_options.is_a?(Hash)
          ship_options = [ship_options]
        end
      end

      ship_options
    end

    def submit_order(order)
      order_xml = order.to_xml_ezporder
      result_xml = submit_http_request("http://order.ezprints.com/PostXmlOrder.axd?PartnerNumber=#{ZangZingConfig.config[:ezp_partner_id]}&PartnerReference=#{order.number}",
          order_xml.to_s, header_options)
      result_xml
    end

    private

    def submit_http_request(url, data, options, redirect_limit = 5)
      raise "Redirect limit reached" if redirect_limit == 0
      redirect_limit -= 1

      #puts data if redirect_limit == 4  # testing hack

      # now send the request
      uri = URI.parse(URI.escape(url))

      http = Net::HTTP.new(uri.host, uri.port)
      query_part = uri.query.nil? ? '' : "?#{uri.query}"
      path_with_query = uri.path + query_part
      response, body = http.post(path_with_query, data, options)

      case response
        when Net::HTTPSuccess
          # fall through to exit
        when Net::HTTPRedirection
          return submit_http_request(url, data, options, redirect_limit) # go again
        else
          raise "HTTP Error returned from ezprints request: #{response.code}"
      end

      puts body.to_s
      result_xml = Nokogiri::XML(body.to_s)
    end

  end
end
