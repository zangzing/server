# this class manages the connections to Redis by providing a single
# instance of the redis class per thread
class ACLManager
  require 'redis'
  require 'config/initializers/zangzing_config'

  # will return an existing redis copy or make a new
  # one and set it to connect to the redis server specified
  # in the config file
  def self.get_redis
    Thread.current['ACLManager.redis'] ||= make_redis
  end

  def self.make_redis
    server = RedisConfig.config[:redis_server]
    parts = server.split(':')
    host = parts[0]
    port = parts[1]
    redis = Redis.new(:host => host, :port => port)
  end
end