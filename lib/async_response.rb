class AsyncResponse
  RESPONSE_EXPIRES_IN = 5.minutes

  class << self

    def new_response_id
      #returns secure guid
#      UUIDTools::UUID.random_create.to_s #.tap{|id| File.open("#{Rails.root}/last_id.txt", 'w'){|f| f.write(id) } }
      "AsyncResponse-#{SecureRandom.hex(16).to_s}"
    end

    def store_response(response_id, response)
      #stores response in memcache
      Rails.cache.write(response_id, response, :expires_in => RESPONSE_EXPIRES_IN)
    end

    def get_response(response_id)
      #fetches response from memcache (or null)
      Rails.cache.read(response_id)
    end
    
    def store_error(response_id, exception)
      info = {
        :exception => true,
        :code => case exception.name
          when 'InvalidToken' then 401
          when 'HttpCallFail' then 503
          else 500
        end,
        :message => exception.message
      }
      Rails.logger.info("AsyncResponse Exception: #{exception.class.name} - #{exception.message}")
      Rails.cache.write(response_id, info.to_json, :expires_in => RESPONSE_EXPIRES_IN)
    end

  end
end