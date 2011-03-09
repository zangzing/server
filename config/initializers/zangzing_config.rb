# need this because the recursively symbolize may not be available when we are called
require "config/initializers/hash_extensions"


# this class hold onto the zangzing_environment data from the same named yml
# use it for generic stuff that you'd like to control on a per environment basis
#

class ZangZingConfig
  def self.config
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../zangzing_config.yml")).result)[Rails.env].recursively_symbolize_keys!
  end
end

# this clsss wraps redis config - putting it here to avoid having too many
# init files - we use RAILS_ENV since calling from rspec does not set up the rails environment
class RedisConfig
  def self.config
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../redis.yml")).result)[Rails.env].recursively_symbolize_keys!
  end
end


