# need this because the recursively symbolize may not be available when we are called
require "config/initializers/hash_extensions"


# this class hold onto the zangzing_environment data from the same named yml
# use it for generic stuff that you'd like to control on a per environment basis
#

class ZangZingConfig
  def self.load
    @@zze_config ||= YAML::load(ERB.new(File.read("#{Rails.root}/config/zangzing_config.yml")).result)[Rails.env].recursively_symbolize_keys!
  end

  def self.zze_config
    load
    @@zze_config
  end
end

# this clsss wraps redis config - putting it here to avoid having too many
# init files - we use RAILS_ENV since calling from rspec does not set up the rails environment
class RedisConfig
  def self.load
#    @@config ||= ZZConfigHelper.recursively_symbolize_keys!(YAML::load(ERB.new(File.read("config/redis.yml")).result)[ENV['RAILS_ENV']])
    @@config ||= YAML::load(ERB.new(File.read("config/redis.yml")).result)[ENV['RAILS_ENV']].recursively_symbolize_keys!
  end

  def self.config
    load
    @@config
  end
end


