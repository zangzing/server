class AsyncResponse
  RESPONSE_EXPIRES_IN = 5.minutes

  class << self

    def new_response_id
      #returns secure guid
#      UUIDTools::UUID.random_create.to_s #.tap{|id| File.open("#{Rails.root}/last_id.txt", 'w'){|f| f.write(id) } }
      "AsyncResponse-#{SecureRandom.hex(16).to_s}"
    end

    # takes a hash and converts to json
    def store_response_hash(response_id, hash)
      response_json = JSON.fast_generate(hash)
      store_response(response_id, response_json)
    end

    def store_response(response_id, response)
      #stores response in memcache
      CacheWrapper.write(response_id, response, {:verify => true, :expires_in => RESPONSE_EXPIRES_IN})
    end

    def get_response(response_id)
      #fetches response from memcache (or null)
      CacheWrapper.read(response_id)
    end

    # exception can be passed as nil, in which
    # case you must supply message and code
    # message can be either a string, array of strings or a hash
    def build_error(exception, message = nil, code = nil)
      info = {
        :exception => exception.nil? ? false : true,
        :exception_name => exception.nil? ? nil : exception.class.name,
        :code => code || case exception.class.name
          when 'InvalidToken' then 401
          when 'HttpCallFail' then 509
          else 509
        end,
        :message => message || exception.message
      }
    end

    # returns the error data as json
    def build_error_json(exception, message = nil, code = nil)
      info = build_error(exception, message, code)
      JSON.fast_generate(info)
    end

    def store_error(response_id, exception)
      error_json = build_error_json(exception)
      Rails.logger.info("AsyncResponse Exception: #{exception.class.name} - #{exception.message}\n#{exception.backtrace}")
      CacheWrapper.write(response_id, error_json, {:verify => true, :expires_in => RESPONSE_EXPIRES_IN})
    end

  end
end