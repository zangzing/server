require "old_acl_base"

class OldSystemRightsACLTuple < OldBaseACLTuple
end

# implements the ACL control for SystemRights
class OldSystemRightsACL < OldBaseACL
  ADMIN_ROLE = ACLRole.new('Admin', 10)
  SUPPORT_HERO_ROLE = ACLRole.new('Hero', 20)
  MODERATOR_ROLE = ACLRole.new('Moderator', 30)
  USER_ROLE = ACLRole.new('User', 40)

  GLOBAL_ID = 1

  def self.initialize
    if OldSystemRightsACL.initialized.nil?
      OldSystemRightsACL.base_init 'SystemRights', make_roles
    end
  end

  # the instance initialization - overrides the default
  # because there is only one of these so use a constant
  def initialize(redis_override = nil)
    super(GLOBAL_ID, redis_override)
  end

  def self.make_roles
    roles = [
        ADMIN_ROLE,
        SUPPORT_HERO_ROLE,
        MODERATOR_ROLE,
        USER_ROLE
    ]
  end

  # get the global instance
  def self.singleton
    @@global_instance ||= OldSystemRightsACL.new
  end


  # make a tuple of our specific type
  # that holds the acl_id and role
  def self.new_tuple
    OldSystemRightsACLTuple.new
  end

  # convert existing users from the database to ACLs
  def self.convert_db_users
    acl = singleton
    users = User.select("id, username, role").all
    users.each do |user|
      user_id = user.id
      user_role = user.role

      # first check to see if the users already has an ACL
      # if so, leave it alone
      if acl.get_user_role(user_id).nil?
        if user_role == "admin"
          role = OldSystemRightsACL::ADMIN_ROLE
        else
          role = OldSystemRightsACL::USER_ROLE
        end
        acl.add_user(user_id, role)
      end
    end
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
    acl.add_user(user.id, role)
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
OldSystemRightsACL.initialize
