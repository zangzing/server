# Turned off but leave this code here in case we need to turn it back on.
# We now have nginx 1.0.1 which should fix all the caching issues but we
# need to verify still.

#module ActionController
#  module ConditionalGet
#
#      #todo: For now we don't let nginx cache anything since it stores cookies
#      # with the cached entries which is very bad since it could allow the wrong
#      # user to pick up the wrong session
#      # once nginx is updated to a version later than 0.8.44 we will no longer need
#      # this patch and can revert to normal behavior
#
#
#    # Sets a HTTP 1.1 Cache-Control header. Defaults to issuing a "private" instruction, so that
#    # intermediate caches shouldn't cache the response.
#    #
#    # Examples:
#    #   expires_in 20.minutes
#    #   expires_in 3.hours, :public => true
#    #   expires in 3.hours, 'max-stale' => 5.hours, :public => true
#    #
#    # This method will overwrite an existing Cache-Control header.
#    # See http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html for more possibilities.
#    def expires_in(seconds, options = {}) #:doc:
#
#      # force to private always for now until we upgrade nginx
#      options[:public] = false
#
#      if ! options[:public]
#        response.headers['X-Accel-Expires'] = '0'
#      end
#
#      response.cache_control.merge!(:max_age => seconds, :public => options.delete(:public))
#      options.delete(:private)
#
#      response.cache_control[:extras] = options.map {|k,v| "#{k}=#{v}"}
#    end
#
#    # Sets a HTTP 1.1 Cache-Control header of "no-cache" so no caching should occur by the browser or
#    # intermediate caches (like caching proxy servers).
#    def expires_now #:doc:
#      response.headers['X-Accel-Expires'] = '0'
#      response.cache_control.replace(:no_cache => true)
#    end
#
#  end
#end
