class AsyncResponse
  class << self

    def new_response_id
      #returns secure guid
#      UUIDTools::UUID.random_create.to_s #.tap{|id| File.open("#{Rails.root}/last_id.txt", 'w'){|f| f.write(id) } }
      "AsyncResponse-#{SecureRandom.hex(16).to_s}"
    end

    def store_response(response_id, response)
      #stores response in memcache
      Rails.cache.write(response_id, response)
    end

    def store_error(response_id, error_code, error_message)
      error = { :error => {
          :code => error_code,
          :message => error_message
      }}
      Rails.cache.write(response_id, JSON.generate(error))
    end

    def get_response(response_id)
      #fetches response from memcache (or null)
      Rails.cache.read(response_id)
    end

  end
end