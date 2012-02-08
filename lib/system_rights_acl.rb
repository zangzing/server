require "acl_base"

class SystemRightsACLTuple < ACLTupleBase
end

# implements the ACL control for SystemRights
class SystemRightsACL < ACLBase
  ADMIN_ROLE = ACLRole.new('Admin', 100)
  SUPPORT_HERO_ROLE = ACLRole.new('Hero', 200)
  SUPER_MODERATOR_ROLE = ACLRole.new('SuperModerator', 250)
  MODERATOR_ROLE = ACLRole.new('Moderator', 300)
  USER_ROLE = ACLRole.new('User', 400)

  GLOBAL_ID = 1

  def self.initialize
    if SystemRightsACL.initialized.nil?
      SystemRightsACL.base_init 'System', nil, make_roles
    end
  end

  # the instance initialization - overrides the default
  # because there is only one of these so use a constant
  def initialize
    super(GLOBAL_ID)
  end

  # order these with most privs first, least last
  def self.make_roles
    roles = [
        ADMIN_ROLE,
        SUPPORT_HERO_ROLE,
        SUPER_MODERATOR_ROLE,
        MODERATOR_ROLE,
        USER_ROLE
    ]
  end

  # get the global instance
  def self.singleton
    @@global_instance ||= SystemRightsACL.new
  end


  # make a tuple of our specific type
  # that holds the acl_id and role
  def self.new_tuple
    SystemRightsACLTuple.new
  end


  # helper methods to be used from rails console

  # helper method that lets you pass a user name
  # and a role name and we add or change the acl
  # for that user - this is a console utility
  # to let you change things by hand
  def self.set_role(user_name, role_name)
    acl = singleton

    # get the user id from the database
    user = User.find_by_username(user_name)
    if user.nil?
      puts "Username: #{user_name} not found in db"
      return
    end
    role = role_name_to_role(role_name)
    if role.nil?
      puts "Role named #{role_name} does not exist."
      return
    end
    acl.add_user(user, role)
  end

  # helper method that lets you pass a user name
  # and we return the string form of the role
  # or nil if not found
  def self.get_role_name(user_name)
    acl = singleton

    # get the user id from the database
    user = User.find_by_username(user_name)
    if user.nil?
      puts "Username: #{user_name} not found in db"
      return nil
    end
    role = acl.get_user_role(user.id)
    if role.nil?
      puts "No roll fouund for #{user_name}"
      return nil
    end
    role.name
  end

end

# let the class initialize and register
SystemRightsACL.initialize
