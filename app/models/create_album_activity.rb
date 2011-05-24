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
end
