require 'hash_extensions'

def safe_rails_env
  if defined?(Rails)
    return Rails.env
  else
    return ENV['RAILS_ENV'] || 'development'
  end
end

class AsyncConfig
  def self.initialize
  end

  def self.config
    @@config ||= YAML::load(File.read(File.dirname(__FILE__) + "/../async_config.yml"))[safe_rails_env].recursively_symbolize_keys!
  end

  def self.logger
    @@logger ||= config[:logger]
  end

  def self.logger=(logger)
    config[:logger] = logger
    @@logger = logger
  end

  def self.server=(server)
    @server = server
  end

  def self.server
    @server
  end
end
