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
  class_inheritable_accessor :roles, :type
  attr_accessor :acl_id

  # call the manager to get the single instance
  # of redis per thread 
  def redis
    @redis ||= ACLManager.get_redis
  end

  # Add a user to an acl - if you specify a user_id it will
  # become the key. On the other hand if user_id is nil and
  # an email is specified it will become the key
  #
  # you also must specify a role which indicates the level
  # of access that this user has against this objects acl
  def add_user_to_acl(user_id, role, user_email = nil)
    if user_id.nil? && user_email.nil?
      raise BaseACLInvalidArguments.new("Must have email or user id")
    end
    id = user_id ? user_id : user_email
    acl_key = build_acl_key
    user_key = build_user_key(id)
    priority = role.priority

    # now store the information in redis as a transaction
    #
    
  end

  def build_acl_key()
    "ACL:#{type}:#{acl_id}"
  end

  def build_user_key(user_id)
    "ACLUser:#{type}:#{user_id}"
  end
end

