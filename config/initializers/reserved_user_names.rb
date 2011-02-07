# this class holds a map of the reserved user names that we don't want
# to be created by users of the site.  In the future we may selectively
# create accounts with some of these names so we want to make sure nobody
# gets one before hand.
class ReservedUserNames

  # this method holds the class level set for the reserved user names
  # put the entries in lower case so we can do a case insensitive compare
  # by setting incoming request to lowercase as well
  #
  # NOTE: Make sure you use lowercase when you add to this set
  #
  # TODO: Plug this into new user creation to perform check
  def self.reserved_users
    @@reserved_users ||= Set.new [
        'zangzing',
        'about',
        'blog',
        'contact',
        'jobs',
        'team',
    ]
  end

  def self.is_reserved?(user)
    l_user = user.downcase
    return reserved_users.include?(l_user)
  end
end