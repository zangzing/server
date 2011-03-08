# need this because the recursively symbolize may not be available when we are called
require "config/initializers/hash_extensions"


# this class hold onto the zangzing_environment data from the same named yml
# use it for generic stuff that you'd like to control on a per environment basis
#

class ZangZingConfig
  def self.load
    # NOTE: Do not change the ENV['RAILS_ENV'] below to be Rails.env since this code is used from an rspec test
    # case and Rails.env is not set up when running those tests
    config_file_path = File.dirname(__FILE__) + "/../zangzing_config.yml"
    @@config ||= YAML::load(ERB.new(File.read(config_file_path)).result)[ENV['RAILS_ENV']].recursively_symbolize_keys!
  end

  def self.config
    load
    @@config
  end
end

# this clsss wraps redis config - putting it here to avoid having too many
# init files - we use RAILS_ENV since calling from rspec does not set up the rails environment
class RedisConfig
  def self.load
    # NOTE: Do not change the ENV['RAILS_ENV'] below to be Rails.env since this code is used from an rspec test
    # case and Rails.env is not set up when running those tests
    config_file_path = File.dirname(__FILE__) + "/../redis.yml"
    @@config ||= YAML::load(ERB.new(File.read(config_file_path)).result)[ENV['RAILS_ENV']].recursively_symbolize_keys!
  end

  def self.config
    load
    @@config
  end
end


