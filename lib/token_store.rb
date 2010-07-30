
class TokenStore

    def initialize(service_name, session)
      @service_name = service_name
      @session = session
      @storage = {}
      reload
    end

    def flush
      File.open(storage_location, 'w') { |out| YAML.dump(@storage, out) }
    end

    def reload
      @storage = YAML.load(File.read(storage_location)) if File.exist?(storage_location)
    end

    def get_token(id = :default)
      @storage[id]
    end

    def delete_token(id = :default)
      @storage.delete(id)
      flush
    end

    def store_token(value, id = :default)
      @storage[id] = value
      flush
    end

  private

    def storage_location
      "#{RAILS_ROOT}/config/#{@service_name}_tokens.yml"
    end
end
