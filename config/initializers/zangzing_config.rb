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

# this clsss wraps resque scheduler config - putting it here to avoid having too many
# init files - we use RAILS_ENV since calling from rspec does not set up the rails environment
class ResqueScheduleConfig
  def self.config
    # don't symbolize keys for this one
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../resque_schedule.yml")).result)[Rails.env]
  end
end

# this clsss wraps redis config - putting it here to avoid having too many
# init files - we use RAILS_ENV since calling from rspec does not set up the rails environment
class MemcachedConfig
  def self.config
    # this is not configred like a typical yml file.  We currently use the engineyard format which the only relevant info is in defaults
    # later we should deploy our own version with proper style
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../memcached.yml")).result)["defaults"].recursively_symbolize_keys!
  end

  # array of servers
  def self.server_list
    return config[:servers]
  end
end

# this clsss wraps resque scheduler config - putting it here to avoid having too many
# init files - we use RAILS_ENV since calling from rspec does not set up the rails environment
class DatabaseConfig
  def self.config
    #
    # NOTE NOTE NOTE
    #
    # we user RAILS_ENV here because we need this from a rspec test and don't want to pull everything in...
    #
    # DO NOT CHANGE
    #
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../database.yml")).result)[ENV['RAILS_ENV']].recursively_symbolize_keys!
  end
end

