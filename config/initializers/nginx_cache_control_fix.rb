module ActionController
  module ConditionalGet


    # Sets a HTTP 1.1 Cache-Control header. Defaults to issuing a "private" instruction, so that
    # intermediate caches shouldn't cache the response.
    #
    # Examples:
    #   expires_in 20.minutes
    #   expires_in 3.hours, :public => true
    #   expires in 3.hours, 'max-stale' => 5.hours, :public => true
    #
    # This method will overwrite an existing Cache-Control header.
    # See http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html for more possibilities.
    def expires_in(seconds, options = {}) #:doc:

      if ! options[:public]
        response.headers['X-Accel-Expires'] = '0'
      end

      response.cache_control.merge!(:max_age => seconds, :public => options.delete(:public))
      options.delete(:private)

      response.cache_control[:extras] = options.map {|k,v| "#{k}=#{v}"}
    end

    # Sets a HTTP 1.1 Cache-Control header of "no-cache" so no caching should occur by the browser or
    # intermediate caches (like caching proxy servers).
    def expires_now #:doc:
      response.headers['X-Accel-Expires'] = '0'
      response.cache_control.replace(:no_cache => true)
    end

  end
end
