# this class manages the connections to Redis by providing a single
# instance of the redis class per thread
class ACLManager
  require 'redis'
  require 'config/initializers/zangzing_config'

  ACL_TYPE = "acl_type".freeze   # base key for an ACL of a given type of object such as album
  ACL_USER = "acl_user".freeze

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

  # return the type tracker which can be used
  # to enumerate the types registered
  def self.type_tracker
    @@type_tracker ||= Set.new()
  end

  # each type of ACL should register here
  # this is so we know which types exist on delete
  # operations for users
  def self.register_type type
    type_tracker.add(type)
  end

  # build a key for an acl object with it's id
  def self.build_acl_key type, acl_id
    ACL_TYPE + ':' + type + ':' + acl_id.to_s
  end

  # build a key for a user of a type of acl object
  # this is the key to represent all objects of the
  # given type that a user is associated with
  def self.build_user_key type, user_id
    ACL_USER + ':' + type + ':' + user_id.to_s
  end

  # the ACLManager manages global user operations that
  # are not necessarily tied to a specific ACL type
  # so it doesn't make sense for them to be in the
  # ACLBase class which manages objects of a specific type
  # and the interactions related to them

  # given an old id, we update all keys
  # and references with the new key for all types
  # of objects that we know about
  def self.replace_user_key old_user_id, new_user_id
    redis = get_redis
#TODO: run this in a transaction with multi
    # iterate across the various types of ACLs that we track
    type_tracker.each do |type|
      old_user_key = build_user_key(type, old_user_id)
      # now fetch its references
      object_ids = redis.zrange(old_user_key, 0, -1, :with_scores => true)
      if (object_ids)
        i = 0
        last = object_ids.length
        while i < last do
          # array has pairs, id, score, id2, score2, ...
          acl_id = object_ids[i]
          i += 1
          score = object_ids[i]
          i += 1

          # one by one remove and readd as the new user id
          acl_key = build_acl_key(type, acl_id)
          redis.zrem(acl_key, old_user_id)
          redis.zadd(acl_key, new_user_id, score)
        end
      end
      # and now rename our user id for this type of object acl
      new_user_key = build_user_key(type, new_user_id)
      redis.rename(old_user_key, new_user_key)
    end
  end

end