module EZPrints
  class EZPManager

    def header_options
#      @@header_options ||= {'Content-Type' => 'text/xml;charset=utf-8'} # ezprints doesn't like the charset here
      @@header_options ||= {'Content-Type' => 'text/xml'}
    end

    # takes an order in the shipping calc format from the order class
    # and transmits that to EZprints returning an array of hashes with the shipping
    # options and prices
    #
    # Returns an array of the shipping option hashes in the form:
    # [
    # {
    #   :type => FC, PM, SD, ON, etc (this is what you include when you want to place an order what they call shipping method on the order side)
    #   :price => cost of shipping
    #   :shippingMethod => USFC, etc (this is not the shipping method used in the actual order, not sure why they include this as it adds little other than confusion)
    #   :description => Description of shipping method
    # }
    # ...
    # ]
    #
    def shipping_costs(order)
      order_xml = order.to_xml_ezporder(:shipping_calc => true)
      result_xml = submit_http_request_with_retry("http://services.ezprints.com/ShippingCalculator/CalculateShipping.axd",
          order_xml.to_s, header_options)
      err = result_xml.at_xpath("/shippingOptions/error")

      if err
        desc = err['description'] || "Error description not returned."
        err_num = err['number'] || -1
        raise EZError.new("Error returned from EZPrints shipping calculator: #{err_num}. #{desc}")
      else
        # put the result into an array of hashes
        path = result_xml.at_xpath("/shippingOptions/order")
        hash = HashConverter.from_xml(path, false, true)
        ship_options = hash[:order][:option]
        if ship_options.is_a?(Hash)
          ship_options = [ship_options]
        end
      end

      ship_options
    end

    def empty_shipping_costs
      @@empty_shipping_costs = {
          :type => 'FC',
          :price => 0.0,
          :shippingMethod => 'USFC',
          :description => 'Place Holder for No Shipping Costs'
      }
    end

    # submit the order to ezprints, if use_test_images
    # is set we just use the placeholder image for testing
    #
    # returns the ezp reference number used later
    # for matching incoming notifications
    #
    def submit_order(order, use_test_images = false)
      order_xml = order.to_xml_ezporder(:shipping_calc => use_test_images)
      result_xml = submit_http_request("http://order.ezprints.com/PostXmlOrder.axd?PartnerNumber=#{ZangZingConfig.config[:ezp_partner_id]}&PartnerReference=#{order.number}",
          order_xml.to_s, header_options)

      order.log_entries.create(:details => result_xml )
      
      # see if we have an error
      err = result_xml.at_xpath("/XmlOrderFailed/@Reason")
      if err
        raise EZError.new("Error returned from EZPrints submit order: #{err}")
      else
        reference = result_xml.at_xpath("/XmlOrder/@Reference")
      end
      reference.to_s
    end

    # these are used because EZPrints notification is tied to
    # a single URL and we would like to be able to receive order
    # notifications in various environments so we prepend
    # a single char that represents our environment.  That way
    # when a notification arrives it can be routed to the proper
    # servers.  Essentially once in production EZPrints will
    # always point at production and from there we will decide
    # where to go or if it should be handle by the current environment
    def prefix_to_host(prefix)
      @@order_routes = {
          'D' => "development.photos.zangzing.com",
          'S' => "staging.photos.zangzing.com",
          'P' => "www.zangzing.com"
      }
      host = @@order_routes[prefix]
    end

    # return the order prefix based on our environment
    def env_to_prefix
      @@env_to_prefix = {
          'development'       => 'D',
          'photos_staging'    => 'S',
          'photos_production' => 'P'
      }
      @@my_prefix ||= @@env_to_prefix[Rails.env]
    end

    # returns the host that we should redirect to if not
    # for us
    # if it's for us we return nil
    def should_redirect_notification_to(order_number)
      return nil if order_number.blank?

      prefix = order_number[0..0] # grab first char
      return nil if prefix == env_to_prefix

      prefix_to_host(prefix)
    end

    #
    # Fetch the marketing insert photo.  We look for
    # the specified user, and then for an album with
    # the specified name.  When that album is found
    # we randomly choose one of the photos contained
    # within it.  If the photo is not found we return
    # a nil which indicates no marketing insert line_item
    # should be created.
    #
    def marketing_insert(user_name = 'zangzing', album_name = 'EZPrint Inserts')
      user = User.find(user_name) rescue nil
      return nil if user.nil?

      album = user.albums.find_by_name(album_name) rescue nil
      return nil if album.nil?

      # find all ready photos
      photos = Photo.where(:user_id => user.id, :album_id => album.id, :state => 'ready').all
      photos_length = photos.nil? ? 0 : photos.length
      return nil if photos_length == 0

      picked_photo = photos[rand(photos_length)]

      return picked_photo
    end

    private
    # perform the request up to the retry_limit if we get an error
    def submit_http_request_with_retry(url, data, options, redirect_limit = 5, retry_limit = 3)
      result = nil

      while retry_limit > 0 do
        retry_limit -= 1
        begin
          result = submit_http_request(url, data, options, redirect_limit)
          break # if we get here we are done since no exception
        rescue Exception => ex
          Rails.logger.error ex.message
          raise ex if retry_limit == 0
          sleep 0.5   # very brief delay before retry
        end
      end

      result
    end

    def submit_http_request(url, data, options, redirect_limit = 5)
      raise EZError.new("Redirect limit reached") if redirect_limit == 0
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
          raise EZError.new("HTTP Error returned from ezprints request: #{response.code}")
      end

      #puts body.to_s
      result_xml = Nokogiri::XML(body.to_s)
    end

  end


  class EZError < StandardError
  end

end
