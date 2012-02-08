#
#   Copyright 2011, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class CreateAlbumActivity < Activity
  # There is no payload, the album id is in the subject
  def payload_valid?
    begin
      return true if subject.is_a?(Album)
    rescue Exception
      return false
    end
  end

  def display_for?( current_user, view )
    return false unless subject
    return true if subject.public?
    return true if view == ALBUM_VIEW && subject.hidden?
    return true if current_user && subject.viewer?( current_user.id )
    false
  end
end
