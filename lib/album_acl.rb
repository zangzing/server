require "acl_base"

class AlbumACLTuple < BaseACLTuple
end

# implements the ACL control for Albums
class AlbumACL < BaseACL
  ADMIN_ROLE = ACLRole.new('Admin', 10)
  CONTRIBUTOR_ROLE = ACLRole.new('Contrib', 20)
  VIEWER_ROLE = ACLRole.new('Viewer', 30)

  def self.initialize
    if AlbumACL.initialized.nil?
      AlbumACL.base_init 'Album', make_roles
    end
  end

  def self.make_roles
    roles = [
        ADMIN_ROLE,
        CONTRIBUTOR_ROLE,
        VIEWER_ROLE
    ]
  end

  # make a tuple of our specific type
  # that holds the acl_id and role
  def self.new_tuple
    AlbumACLTuple.new
  end

end

# let the class initialize and register
AlbumACL.initialize
