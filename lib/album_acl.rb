require "base_acl"

# implements the ACL control for Albums
class AlbumACL < BaseACL
  ADMIN_ROLE = ACLRole.new('Admin', 1)
  CONTRIBUTOR_ROLE = ACLRole.new('Contrib', 2)
  VIEWER_ROLE = ACLRole.new('Viewer', 3)

  def initialize(album_id)
    self.acl_id = album_id
    AlbumACL.roles ||= make_roles
    AlbumACL.type ||= 'Album'
  end

  def make_roles
    roles = [
        ADMIN_ROLE,
        CONTRIBUTOR_ROLE,
        VIEWER_ROLE
    ]
  end
end