require "active_support/core_ext/class/inheritable_attributes"
require "acl_role"
require "acl_manager"
require "redis"

# exception classes for ACL

# the arguments passed are invalid
class OldBaseACLInvalidArguments < Exception
end

# this is a base container class that holds a single id and role value
# for a given ACL Type
# it is used when we want to get a list of objects that are associated
# with a particular user such as all my Albums and my role
class OldBaseACLTuple
  attr_accessor :acl_id, :role
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
# Having two synchronized lists allows us to efficiently ask questions
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
class OldBaseACL
  class_inheritable_accessor :initialized, :roles, :type, :role_value_first, :role_value_last, :priority_to_role
  attr_accessor :acl_id, :redis

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
    OldACLManager.register_type type
    self.initialized = true
  end

  # the instance initialization
  def initialize(acl_id, redis_override = nil)
    @redis = redis_override.nil? ? OldACLManager.get_global_redis : redis_override
    self.acl_id = acl_id
  end

  # given the priority, return the role
  def self.get_role(role_value)
    self.priority_to_role[role_value.to_i]
  end

  # build the key used to store the acl to user set
  #
  def build_acl_key()
    @acl_key ||= OldACLManager.build_acl_key(type, acl_id)
  end

  # build the key to store the type:user to acl objects
  #
  def self.build_user_key(user_id)
    OldACLManager.build_user_key(self.type, user_id)
  end

  # helper to convert a role name to a role
  # case insensitive
  def self.role_name_to_role(role_name)
    roles = self.roles
    l_match = role_name.downcase
    roles.each do |role|
      l_roll_name = role.name.downcase
      if l_roll_name == l_match
        return role
      end
    end
    return nil
  end


  # Add a user to an acl or modify an existing users role.
  #
  # You also must specify a role which indicates the level
  # of access that this user has against this objects acl
  #
  # The user_id can actually be
  # an email or the numerical id.  If you use an email
  # you should call global_replace_user_key once you have
  # the actual id so that the access code can be consistent
  #
  # For example, for cases where we have no user id, always
  # refer to this user with email.  But once we convert a
  # user and it has a real id use that even though we now
  # have both email and user id.  This way the transition point
  # becomes as soon as we have a user id we always use that.
  #
  # To change a users key you must use:
  # ACLManager.global_replace_user_key
  # You call the manager rather than an ACL instance because
  # changing the user key can affect more than one ACL Type
  #
  # Note: This call will modify an existing users role
  # if you add and the user already exists.
  #
  def add_user(user_id, role)
    user_id = OldACLManager.safe_id(user_id)
    acl_key = build_acl_key
    user_key = self.class.build_user_key(user_id)
    priority = role.priority

    # now store the information in redis as a transaction
    #
    redis.multi do
      redis.pipelined do
        redis.zadd acl_key, priority, user_id
        redis.zadd user_key, priority, acl_id
      end
    end
    notify_user_acl_modified([user_id])
  end
    
  # Remove the user from the acl
  #
  def remove_user(user_id)
    user_id = OldACLManager.safe_id(user_id)
    acl_key = build_acl_key
    user_key = self.class.build_user_key(user_id)

    # now remove from both sets as a transaction
    #
    redis.multi do
      redis.pipelined do
        redis.zrem acl_key, user_id
        redis.zrem user_key, acl_id
      end
    end
    notify_user_acl_modified([user_id])
  end

  # Remove an acl - removes all users from the
  # set and then removes from all users
  #
  def remove_acl
    acl_key = build_acl_key
    first_value = self.role_value_first
    last_value = self.role_value_last

    # utilize optimistic locking to ensure
    # we have a consistent set removal
    completed = false
    while completed == false
      # this is the optimistic lock key that
      # we are monitoring if it changes our exec will fail
      # and we will need to try again
      redis.watch acl_key

      # get the user ids so we can remove our reference
      user_ids = redis.zrangebyscore acl_key, first_value, last_value
      curr = 0
      count = user_ids.nil? ? 0 : user_ids.length

      single_pipeline = count <= OldACLManager::PIPE_LINE_MAX

      result = redis.multi do
        while curr < count do
          redis.pipelined do
            while curr < count do
              user_id = user_ids[curr]
              user_key = self.class.build_user_key(user_id)
              redis.zrem user_key, acl_id
              curr = curr + 1
              break if (curr % OldACLManager::PIPE_LINE_MAX) == 0
            end
            redis.zremrangebyscore acl_key, first_value, last_value if single_pipeline
          end
        end
        # now remove all the values for this key
        redis.zremrangebyscore acl_key, first_value, last_value if single_pipeline == false
      end
      completed = result.nil? ? false : true
    end
    notify_user_acl_modified(user_ids)
    return true
  end

  # override this if you want to be notified of a users acl being modified in some way
  def notify_user_acl_modified(user_ids)
  end

  # return the user role if we have one for the
  # given user_id.  If no role we return nil
  def get_user_role(user_id)
    user_id = OldACLManager.safe_id(user_id)
    priority = redis.zscore(build_acl_key, user_id)
    if !priority.nil?
      # now we have the score, transform into a role object
      return self.class.get_role(priority)
    else
      return nil
    end
  end

  # see if has rights at least as high as
  # role passed
  #
  # if exact is set to true then only the same
  # role will be a match
  #
  def has_permission?(user_id, role, exact = false)
    user_id = OldACLManager.safe_id(user_id)
    priority = redis.zscore(build_acl_key, user_id)
    if !priority.nil?
      # now we have the score, transform into a role object
      user_role = self.class.get_role(priority)
      return exact ? user_role.priority == role.priority : user_role.priority <= role.priority
    else
      return false
    end
  end

  # returns a list of user_ids that match a specific role
  #
  # as in has_permission? the matching is done based on priority
  # so a user that is an admin would match that of viewer but
  # not the other way around.
  #
  # if the exact flag is set then we only return matches for that
  # specific role
  #
  def get_users_with_role(role, exact = false)
    acl_key = build_acl_key

    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first

    user_ids = redis.zrangebyscore acl_key, first, last
  end

  # the follow section of methods are related to this ACL type but are class methods
  # because they are not for a particular acl but a group of them


  # build the tuple that contains the acl_id to role pairing
  # used when returning the list of owned acls for a specific
  # user
  def self.build_tuple acl_id, role_value
    t = self.new_tuple
    role = get_role(role_value)
    t.acl_id = acl_id
    t.role = role
    return t
  end



  # Find all the acls for a given user with rights at least as high as
  # the role passed.  If exact is specified we match only the specific
  # role specified.
  #
  # We return the results as an array of ACLTuples of our specific type
  #
  # If none we return nil
  #
  def self.get_acls_for_user(user_id, role, exact = false, redis_override = nil)
    user_id = OldACLManager.safe_id(user_id)
    redis = redis_override.nil? ? OldACLManager.get_global_redis : redis_override
    user_key = build_user_key(user_id)

    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first

    object_ids = redis.zrangebyscore user_key, first, last, :with_scores => true

    # now walk the ids and turn them into tuples
    tuples = nil
    if (object_ids)
      tuples = []
      i = 0
      last = object_ids.length
      while i < last do
        # array has pairs, id, score, id2, score2, ...
        acl_id = object_ids[i]
        i += 1
        role_value = object_ids[i]
        i += 1

        tuple = build_tuple(acl_id, role_value)

        tuples << tuple
      end
    end
    return tuples
  end

  # convenience method to fetch all the acls for a given user
  def self.get_all_acls_for_user(user_id, redis_override = nil)
    user_id = OldACLManager.safe_id(user_id)
    return get_acls_for_user(user_id, roles.last, false)
  end
end



