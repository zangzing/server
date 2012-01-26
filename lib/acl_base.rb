require "acl_role"
require "acl_manager"

# exception classes for ACL

# the arguments passed are invalid
class ACLInvalidArguments < Exception
end

# this is a base container class that holds a single id and role value
# for a given ACL Type
# it is used when we want to get a list of objects that are associated
# with a particular user such as all my Albums and my role
class ACLTupleBase
  attr_accessor :acl_id, :role
end

# this is the base ACL management class - it provides the low level
# interfaces to the db to perform ACL operations.  You should inherit
# this to create a specific type of ACL.  For instance you might have
# an ACL on Albums and maybe later on some other type of object that
# you want to control
#
# The ACL operates primarily on groups although we also provide
# handy methods to discover permissions based on a user id where
# we traverse any groups that the user belongs to as it applies
# to the acl being checked.
#
#
# We support asking questions like:
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
class ACLBase
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
    ACLManager.register_type type
    self.initialized = true
  end

  # the instance initialization
  def initialize(acl_id)
    self.acl_id = acl_id
  end

  # given the priority, return the role
  def self.get_role(role_value)
    self.priority_to_role[role_value.to_i]
  end

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


  # Add a group to an acl or modify an existing groups role.
  #
  # You also must specify a role which indicates the level
  # of access that this user has against this objects acl
  #
  # Note: This call will modify an existing groups role
  # if you add and the user already exists.
  #
  # If you want to operate as if you had a user you
  # can supply the my_group_id from the user object
  # as the group id.  All users get a special group
  # that wraps that user and only contains that user
  # in its members.
  #
  def add_group(group_id, role)
    priority = role.priority
    rows = [[acl_id, type, group_id, priority]]
    affected_user_ids = ACL.update_groups(rows)
    notify_user_acl_modified(affected_user_ids)
  end

  # Remove the group from the acl
  #
  def remove_group(group_id)
    rows = [[acl_id, type, group_id]]
    affected_user_ids = ACL.remove_groups(rows)
    notify_user_acl_modified(affected_user_ids)
  end

  # Remove an acl - removes all users from the
  # set and then removes from all users
  #
  def remove_acl
    rows = [[acl_id, type]]
    affected_user_ids = ACL.delete_acls(rows)
    notify_user_acl_modified(affected_user_ids)
    return true
  end

  # override this if you want to be notified of a users acl being modified in some way
  def notify_user_acl_modified(user_ids)
  end

  # return the user role if we have one for the
  # given user_id.  If no role we return nil
  def get_user_role(user_id)
    priority = ACL.role_for_user(user_id, acl_id, type)
    priority.nil? ? nil : self.class.get_role(priority)
  end

  # return the user role if we have one for the
  # given user_id.  If no role we return nil
  def get_group_role(group_id)
    priority = ACL.role_for_group(group_id, acl_id, type)
    priority.nil? ? nil : self.class.get_role(priority)
  end

  # see if user has rights at least as high as
  # role passed
  #
  # if exact is set to true then only the same
  # role will be a match
  #
  def has_permission?(user_id, role, exact = false)
    priority = ACL.role_for_user(user_id, acl_id, type)
    priority.nil? ? false : exact ? priority == role.priority : priority <= role.priority
  end

  # see if group has rights at least as high as
  # role passed
  #
  # if exact is set to true then only the same
  # role will be a match
  #
  def group_has_permission?(group_id, role, exact = false)
    priority = ACL.role_for_group(group_id, acl_id, type)
    priority.nil? ? false : exact ? priority == role.priority : priority <= role.priority
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
    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first
    user_ids = ACL.users_with_role(acl_id, type, first, last)
  end

  # returns a list of group_ids that match a specific role
  #
  # as in has_permission? the matching is done based on priority
  # so a user that is an admin would match that of viewer but
  # not the other way around.
  #
  # if the exact flag is set then we only return matches for that
  # specific role
  #
  def get_groups_with_role(role, exact = false)
    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first
    group_ids = ACL.groups_with_role(acl_id, type, first, last)
  end


  # the following section of methods are related to this ACL type but are class methods
  # because they are not for a particular acl but a group of them


  # Find all the acls for a given user with rights at least as high as
  # the role passed.  If exact is specified we match only the specific
  # role specified.
  #
  # We return the results as an array of ACLTuples of our specific type
  #
  # If none we return and empty array
  #
  def self.get_acls_for_user(user_id, role, exact = false)
    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first

    rows = ACL.acls_for_user(user_id, type, first, last)

    tuples = []
    rows.each do |row|
      tuples << build_tuple(row[0], row[1])
    end

    return tuples
  end

  # Find all the acls for a given group with rights at least as high as
  # the role passed.  If exact is specified we match only the specific
  # role specified.
  #
  # We return the results as an array of ACLTuples of our specific type
  #
  # If none we return and empty array
  #
  def self.get_acls_for_group(group_id, role, exact = false)
    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first

    rows = ACL.acls_for_group(user_id, type, first, last)

    tuples = []
    rows.each do |row|
      tuples << build_tuple(row[0], row[1])
    end

    return tuples
  end

  # convenience method to fetch all the acls for a given user
  def self.get_all_acls_for_user(user_id)
    return get_acls_for_user(user_id, roles.last, false)
  end

  # convenience method to fetch all the acls for a given group
  def self.get_all_acls_for_group(group_id)
    return get_acls_for_group(group_id, roles.last, false)
  end

end