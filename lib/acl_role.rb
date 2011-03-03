# this class defines a role - roles
# are defined as a priority where the lower
# number has all the rights of the higher numbered
# roles.  So for example we might have:
# Admin => 1
# Contributor => 2
# Viewer => 3
#
# when rights checks are done and we want to know if
# a user has viewer rights it can be either a viewer,
# contributor, or admin.
# likewise if a user is an admin and we want to know
# if it has admin rights then we will only match the
# admin role because no other roles are higher priority
#
class ACLRole
  attr_accessor :name, :priority

  def initialize(name, priority)
    self.name = name
    self.priority = priority
  end

  # return true if the current role has
  # at least the level of privileges as the
  # role specified
  def has_permission(role)
    self.priority <= role.priority
  end
end
