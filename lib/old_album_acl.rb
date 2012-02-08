require "old_acl_base"

class OldAlbumACLTuple < OldBaseACLTuple
end

# implements the ACL control for Albums
class OldAlbumACL < OldBaseACL
  ADMIN_ROLE = ACLRole.new('Admin', 10)
  CONTRIBUTOR_ROLE = ACLRole.new('Contrib', 20)
  VIEWER_ROLE = ACLRole.new('Viewer', 30)

  def self.initialize
    if OldAlbumACL.initialized.nil?
      OldAlbumACL.base_init 'Album', make_roles
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
    OldAlbumACLTuple.new
  end

  # called by base class to inform us that the user acl has
  # been modified in some way for the set of users given
  # currently we only care that a modification happened so
  # we don't need the specifics
  def notify_user_acl_modified(user_ids)
    user_ids.each do |user_id|
      #todo call album cache manager here to let it know
      # it should invalidate the trackers for this user on
      # contributor albums
      num_user_id = user_id.to_i
      if num_user_id != 0
        # only notify if it is a valid numeric user id
        Cache::Album::Manager.shared.user_albums_acl_modified([num_user_id])
      end
    end
  end

end

# let the class initialize and register
OldAlbumACL.initialize
