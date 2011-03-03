require "acl_base"

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

  def initialize(album_id)
    AlbumACL.initialize
    self.acl_id = album_id
  end

end

# let the class initialize and register
AlbumACL.initialize
