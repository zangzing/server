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

# this class instance is notified when changes happen
# to an underlying group membership
# the base class has the behavior of doing nothin
# currently this is not hooked up to anything see the groups_controller
# zz_api_add_members method for more info
class ACLGroupHandler
  def added_members(group_id, resource_id, user_ids)
  end
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

  # initialize the class, type is the type of acl such as Album
  # group_handler is an instance of a class that will be notified on changes to groups via the ACLManager
  def self.base_init type, group_handler, roles
    self.type = type
    self.roles = roles
    self.role_value_first = self.roles.first.priority   # highest priority
    self.role_value_last = self.roles.last.priority     # lowest priority
    # make a map of priority to role for quick lookup
    # later
    self.priority_to_role = Hash.new()
    roles.each do |role|
      self.priority_to_role[role.priority] = role
    end
    group_handler ||= ACLGroupHandler.new   # default if not passed in
    ACLManager.register_type type, group_handler
    self.initialized = true
  end

  # the instance initialization
  def initialize(acl_id)
    raise ArgumentError.new("acl_id must be an Integer") unless acl_id.is_a?(Integer)
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

  # builds a hash containing keys of role to empty arrays
  def self.hash_of_arrays_for_roles
    hash = {}
    roles.each do |role|
      hash[role] = []
    end
    hash
  end

  # Add a set of groups to an acl or modify an existing groups role.
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
  # Returns an array of the affected user ids
  #
  def add_groups(group_ids, role)
    group_ids = Array(group_ids)
    priority = role.priority
    rows = build_group_rows(group_ids, priority)
    affected_user_ids = ACL.update_groups(rows)
    notify_user_acl_modified(affected_user_ids)
    affected_user_ids
  end

  # helper that adds a user by fetching it's wrapped group
  def add_user(user, role)
    raise ArgumentError.new("user must be a User") unless user.is_a?(User)
    add_groups(user.my_group_id, role)
  end

  # Remove the group from the acl
  #
  #
  # Returns an array of the affected user ids
  #
  def remove_groups(group_ids)
    group_ids = Array(group_ids)
    rows = build_group_rows(group_ids)
    affected_user_ids = ACL.remove_groups(rows)
    notify_user_acl_modified(affected_user_ids)
    affected_user_ids
  end

  def build_group_rows(group_ids, priority = nil)
    rows = []
    group_ids.each do |group_id|
      rows << [acl_id, type, group_id, priority]
    end
    rows
  end

  # helper that removes a user by fetching it's wrapped group
  def remove_user(user)
    raise ArgumentError.new("user must be a User") unless user.is_a?(User)
    remove_groups(user.my_group_id)
  end

  # Remove an acl - removes all users from the
  # acl (an acl with no members has no database entry)
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
    raise ArgumentError.new("user_id must be an Integer") unless user_id.is_a?(Integer)
    priority = ACL.role_for_user(user_id, acl_id, type)
    priority.nil? ? nil : self.class.get_role(priority)
  end

  # return the user role if we have one for the
  # given user_id.  If no role we return nil
  def get_group_role(group_id)
    raise ArgumentError.new("group_id must be an Integer") unless group_id.is_a?(Integer)
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
    raise ArgumentError.new("user_id must be an Integer") unless user_id.is_a?(Integer)
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
    raise ArgumentError.new("group_id must be an Integer") unless group_id.is_a?(Integer)
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
    rows = users_and_roles(role, exact)
    user_ids = rows.map {|r| r[0]}
  end

  # returns a hash having a key for each role that contains the list
  # of users for that role
  #
  # as in has_permission? the matching is done based on priority
  # so a user that is an admin would match that of viewer but
  # not the other way around.
  #
  # if the exact flag is set then we only return matches for that
  # specific role
  #
  # {
  #   role1 => [user_id,...]   where role is a role such as AlbumACL::ADMIN_ROLE
  #   role2 => [user_id,...]   where role is a role such as AlbumACL::ADMIN_ROLE
  #   ...
  # }
  def get_users_and_roles
    rows = users_and_roles(self.class.roles.last, false)
    return make_roles_to_ids(rows)
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
    rows = groups_and_roles(role, exact)
    group_ids = rows.map {|r| r[0]}
  end

  # returns a hash having a key for each role that contains the list
  # of groups for that role
  #
  # {
  #   role1 => [group_id,...]   where role is a role such as AlbumACL::ADMIN_ROLE
  #   role2 => [group_id,...]   where role is a role such as AlbumACL::ADMIN_ROLE
  #   ...
  # }
  def get_groups_and_roles
    rows = groups_and_roles(self.class.roles.last, false)
    return make_roles_to_ids(rows)
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
    raise ArgumentError.new("user_id must be an Integer") unless user_id.is_a?(Integer)
    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first

    rows = ACL.acls_for_user(user_id, type, first, last)

    return build_tuples(rows)
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
    raise ArgumentError.new("group_id must be an Integer") unless group_id.is_a?(Integer)
    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first

    rows = ACL.acls_for_group(group_id, type, first, last)

    return build_tuples(rows)
  end

  # convenience method to fetch all the acls for a given user
  def self.get_all_acls_for_user(user_id)
    return get_acls_for_user(user_id, roles.last, false)
  end

  # convenience method to fetch all the acls for a given group
  def self.get_all_acls_for_group(group_id)
    return get_acls_for_group(group_id, roles.last, false)
  end

private

  # build up tuples for rows of the form
  # [[resource_id, role],...]
  def self.build_tuples(rows)
    tuples = []
    rows.each do |row|
      tuples << build_tuple(row[0], row[1])
    end
    tuples
  end

  # fetch the users and roles array
  # [[user_id, role]...]
  def users_and_roles(role, exact)
    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first
    rows = ACL.users_with_role(acl_id, type, first, last)
  end

  # get groups and roles
  # [[group_id, role], ...]
  def groups_and_roles(role, exact)
    # get the priority range
    last = role.priority
    first = exact ? last : self.role_value_first
    rows = ACL.groups_with_role(acl_id, type, first, last)
  end

  # takes rows and turns them into role to id has
  # rows in form
  # [[id, role]...]
  def make_roles_to_ids(rows)
    roles = self.class.hash_of_arrays_for_roles
    rows.each do |row|
      role = self.class.get_role(row[1])
      ids = roles[role]
      ids << row[0]   # append the id
    end
    roles
  end

end