require "active_support/core_ext/class/inheritable_attributes"
require "acl_role"
require "acl_manager"
require "redis"

# exception classes for ACL

# the arguments passed are invalid
class BaseACLInvalidArguments < Exception
end

# this is the base ACL management class - it provides the low level
# interfaces to redis to perform ACL operations.  You should inherit
# this to create a specific type of ACL.  For instance you might have
# an ACL on Albums and maybe later on some other type of object that
# you want to control
#
#
# We use redis sorted sets to hold two key lists.  The first list
# is tied to a specific object of a specific type.  So for instance
# we would have a key for a specific album that lets us track all the
# users along with their roles (through the order value).
#
# Along side the object acl we have a second user tracking list that
# has an individual user and all the ACLs they track for a specific
# type of object such as Album.  Below I show examples that talk about
# albums specifically but we are general purpose and new types can
# be added in the future through class inheritance.  Today we only
# have a child class type of AlbumACL.
#
# Having to synchronized lists allows us to efficiently ask questions
# like:
#
# 1) What is the specific role of this user on a particular album.
#
# 2) Does this user have rights to be a specific role with inheritance.
# For instance, if I am an admin and you are checking for viewer rights
# the request will be granted.  On the other hand if you are a viewer
# and we ask for admin rights it will not be permitted.
#
# 3) Show me all the admins, contribs, viewers for an object.  You can
# match based on inheritance as in #2 or specific as in #1.
#
# 4) Show me all the albums that a specific user has a role for and what
# those roles are.
#
# 5) Ask for a subset of objects for a given type that match a specific
# role filter.  Such as show me all my objects that I am an admin for.
# 
class BaseACL
  class_inheritable_accessor :initialized, :roles, :type, :role_value_first, :role_value_last, :priority_to_role
  attr_accessor :acl_id

  def self.base_init type, roles
    self.type = type
    self.roles = roles
    self.role_value_first = self.roles.first.priority
    self.role_value_last = self.roles.last.priority
    # make a map of priority to role for quick lookup
    # later
    self.priority_to_role = Hash.new()
    roles.each do |role|
      self.priority_to_role[role.priority] = role
    end
    ACLManager.register_type type
    self.initialized = true
  end

  # given the priority, return the role
  def get_role(priority)
    self.priority_to_role[priority.to_i]
  end

  # call the manager to get the single instance
  # of redis per thread 
  def redis
    @redis ||= ACLManager.get_redis
  end

  # build the key used to store the acl to user set
  #
  def build_acl_key()
    @@acl_key ||= ACLManager.build_acl_key(type, acl_id)
  end

  # build the key to store the type:user to acl objects
  #
  def build_user_key(user_id)
    ACLManager.build_user_key(type, user_id)
  end

  # Add a user to an acl - The user_id can actually be
  # an email or the numerical id.  If you use an email
  # you should call replace_user_key once you have
  # the actual id so that the access code can be consistent
  #
  # For example, for cases where we have no user id, always
  # refer to this user with email.  But once we convert a
  # user and it has a real id use that even though we now
  # have both email and user id.  This way the transition point
  # becomes as soon as we have a user id we always use that.
  #
  # you also must specify a role which indicates the level
  # of access that this user has against this objects acl
  def add_user_to_acl(user_id, role)
    acl_key = build_acl_key
    user_key = build_user_key(user_id)
    priority = role.priority

    # now store the information in redis as a transaction
    #
    redis.multi do
      redis.pipelined do
        redis.zadd acl_key, priority, user_id
        redis.zadd user_key, priority, acl_id
      end
    end
  end
    
  # Remove the user from the acl
  #
  def remove_user_from_acl(user_id)
    acl_key = build_acl_key
    user_key = build_user_key(user_id)

    # now remove from both sets as a transaction
    #
    redis.multi do
      redis.pipelined do
        redis.zrem acl_key, user_id
        redis.zrem user_key, acl_id
      end
    end
  end

  # Remove an acl - removes all users from the
  # set and then removes from all users
  #
  def remove_acl
    acl_key = build_acl_key
    first = self.role_value_first
    last = self.role_value_last

    # utilize optimistic locking to ensure
    # we have a consistent set removal
    completed = false
    while completed == false
      # this is the optimistic lock key that
      # we are monitoring if it changes our exec will fail
      # and we will need to try again
      redis.watch acl_key

      # get the user ids so we can remove our reference
      user_ids = redis.zrangebyscore acl_key, first, last
      result = redis.multi do
        redis.pipelined do
          user_ids.each do |user_id|
            user_key = build_user_key(user_id)
            redis.zrem user_key, acl_id
          end

          # now remove all the values for this key
          redis.zremrangebyscore acl_key, first, last
        end
      end
      completed = result.nil? ? false : true
    end
    true
  end

  # return the user role if we have one for the
  # given user_id.  If no role we return nil
  def get_user_role(user_id)
    r = redis.zrangebyscore(build_acl_key, self.role_value_first, self.role_value_last, :with_scores => true)
    if !r.nil?
      score = r[1]
      # now we have the score, transform into a role object
      return get_role(score)
    else
      return nil
    end
  end
end

