require "acl_base"

class AlbumACLTuple < ACLTupleBase
end

# this class instance is notified when changes happen
# to an underlying group membership - this class is a
# singleton created on init of the AlbumACL
# NOT CURRENTLY ACTIVE
class AlbumGroupHandler < ACLGroupHandler
  def added_members(group_id, resource_id, user_ids)
    album = Album.find_by_id(resource_id)
    if album
      album.group_users_added(group_id, user_ids)
    end
  end
end

# implements the ACL control for Albums
class AlbumACL < ACLBase
  ADMIN_ROLE = ACLRole.new('Admin', 100)
  CONTRIBUTOR_ROLE = ACLRole.new('Contrib', 200)
  VIEWER_ROLE = ACLRole.new('Viewer', 300)

  def self.initialize
    if AlbumACL.initialized.nil?
      AlbumACL.base_init 'Album', AlbumGroupHandler.new, make_roles
    end
  end

  # order these with most privs first, least last
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

  # called by base class to inform us that the user acl has
  # been modified in some way for the set of users given
  # currently we only care that a modification happened so
  # we don't need the specifics
  def notify_user_acl_modified(user_ids)
    Cache::Album::Manager.shared.user_albums_acl_modified(user_ids)
  end

end


# let the class initialize and register
AlbumACL.initialize
