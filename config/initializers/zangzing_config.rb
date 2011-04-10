# need this because the recursively symbolize may not be available when we are called
require "config/initializers/hash_extensions"


# this class hold onto the zangzing_environment data from the same named yml
# use it for generic stuff that you'd like to control on a per environment basis
#

# determine the rails env in a manner that works
# with rspec tests and directly from rails
def safe_rails_env
  if defined?(Rails)
    return Rails.env
  else
    return ENV['RAILS_ENV']
  end
end

class ZangZingConfig
  def self.initialize
    @@running_as_resque = false
  end

  def self.config
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../zangzing_config.yml")).result)[safe_rails_env].recursively_symbolize_keys!
  end

  def self.new_relic_category_type
    @@running_as_resque ||= false # initialize if not done yet
    @@running_as_resque ? :task : :controller
  end

  # set to true if running under resque
  # this lets us know how to categorize NewRelic instrumentation
  def self.running_as_resque=(flag)
    @@running_as_resque = flag
  end
end

# this class wraps redis config - putting it here to avoid having too many
# init files
class RedisConfig
  def self.config
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../redis.yml")).result)[safe_rails_env].recursively_symbolize_keys!
  end
end

# this class wraps resque scheduler config - putting it here to avoid having too many
# init files
class ResqueScheduleConfig
  def self.config
    # don't symbolize keys for this one
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../resque_schedule.yml")).result)[safe_rails_env]
  end
end

# this class wraps redis config - putting it here to avoid having too many
# init files
class MemcachedConfig
  def self.config
    # this is not configured like a typical yml file.  We currently use the engineyard format which the only relevant info is in defaults
    # later we should deploy our own version with proper style
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../memcached.yml")).result)["defaults"].recursively_symbolize_keys!
  end

  # array of servers
  def self.server_list
    return config[:servers]
  end
end

# this class wraps database config - putting it here to avoid having too many
# init files
class DatabaseConfig
  def self.config
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../database.yml")).result)[safe_rails_env].recursively_symbolize_keys!
  end
end

# this class wraps the cache database config - putting it here to avoid having too many
# init files
class CacheDatabaseConfig
  def self.config
    #
    # this config comes from the sub_migrates/cache_builder - this allows us to have a seperate
    # sub project that gets its own config to point to a different database than the main app
    # and also provides us with the ability to run the migrations from that sub project
    @@config ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../sub_migrates/cache_builder/config/database.yml")).result)[safe_rails_env].recursively_symbolize_keys!
  end
end
