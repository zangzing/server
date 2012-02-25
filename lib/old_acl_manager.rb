# this class manages the connections to Redis by providing a single
# instance of the redis class per thread
class OldACLManager
  require 'redis'
  require 'config/initializers/zangzing_config'

  PIPE_LINE_MAX = 1000
  ACL_TYPE = "acl_type".freeze   # base key for an ACL of a given type of object such as album
  ACL_USER = "acl_user".freeze

  #
  # Returns the single global redis instance
  # if you want a custom instance you can
  # call make_redis, or Redis.new directly
  #
  def self.get_global_redis
    @@global_redis ||= make_redis
  end

  def self.make_redis
    server = RedisConfig.config[:redis_acl_server]
    parts = server.split(':')
    host = parts[0]
    port = parts[1]
    db = parts[2].nil? ? 0 : parts[2]
    redis = Redis.new(:host => host, :port => port, :db => db)
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

  # force to lower case if id is a string
  def self.safe_id(id)
    if id.is_a?(String)
      return id.downcase
    else
      return id
    end
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
  #
  # takes optionally an instance of redis to use
  # so you can override the use of the global instance
  #
  def self.global_replace_user_key old_user_id, new_user_id, redis_override = nil
    redis = redis_override.nil? ? get_global_redis : redis_override

    old_user_id = safe_id(old_user_id)
    new_user_id = safe_id(new_user_id)

   # iterate across the various types of ACLs that we track
    type_tracker.each do |type|
      old_user_key = build_user_key(type, old_user_id)
      new_user_key = build_user_key(type, new_user_id)

      # utilize optimistic locking to ensure
      # we have a consistent set removal
      completed = false
      while completed == false
        # this is the optimistic lock key that
        # we are monitoring if it changes our exec will fail
        # and we will need to try again
        redis.watch old_user_key

        # now fetch its references
        object_ids = redis.zrange(old_user_key, 0, -1, :with_scores => true)
        i = 0
        count = object_ids.nil? ? 0 : object_ids.length
        if (count == 0)
          break # nothing to do, move on to next
        end

        single_pipeline = count <= OldACLManager::PIPE_LINE_MAX

        result = redis.multi do
          while i < count do
            redis.pipelined do
              while i < count do
                # array has pairs, id, score, id2, score2, ...
                acl_id = object_ids[i]
                i += 1
                score = object_ids[i]
                i += 1

                # one by one remove and readd as the new user id
                acl_key = build_acl_key(type, acl_id)
                redis.zrem(acl_key, old_user_id)
                redis.zadd(acl_key, score, new_user_id)

                break if (i % OldACLManager::PIPE_LINE_MAX) == 0
              end
              # and now rename our user id for this type of object acl
              redis.rename(old_user_key, new_user_key) if single_pipeline
            end
          end
          # and now rename our user id for this type of object acl
          redis.rename(old_user_key, new_user_key) if single_pipeline == false
        end
        completed = result.nil? ? false : true
      end
    end
  end

  # Given a user id, delete all references to that
  # user.
  def self.global_delete_user user_id, redis_override = nil
    redis = redis_override.nil? ? get_global_redis : redis_override

    user_id = safe_id(user_id)

   # iterate across the various types of ACLs that we track
    type_tracker.each do |type|
      user_key = build_user_key(type, user_id)

      # utilize optimistic locking to ensure
      # we have a consistent set removal
      completed = false
      while completed == false
        # this is the optimistic lock key that
        # we are monitoring if it changes our exec will fail
        # and we will need to try again
        redis.watch user_key

        # now fetch its references
        object_ids = redis.zrange(user_key, 0, -1, :with_scores => true)
        i = 0
        count = object_ids.nil? ? 0 : object_ids.length
        if (count == 0)
          break # nothing to do, move on to next
        end

        # max is double because we have two array items per actual call
        pipe_line_max = OldACLManager::PIPE_LINE_MAX * 2
        single_pipeline = count <= pipe_line_max

        result = redis.multi do
          while i < count do
            redis.pipelined do
              while i < count do
                # array has pairs, id, score, id2, score2, ...
                acl_id = object_ids[i]
                i += 1
                score = object_ids[i]
                i += 1

                # one by one remove and readd as the new user id
                acl_key = build_acl_key(type, acl_id)
                redis.zrem(acl_key, user_id)

                break if (i % pipe_line_max) == 0
              end
              # and now delete the user tracker for this type of acl object
              redis.del(user_key) if single_pipeline
            end
            # and now delete the user tracker for this type of acl object
            redis.del(user_key) if single_pipeline == false
          end
        end
        completed = result.nil? ? false : true
      end
    end
  end

end