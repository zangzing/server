#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class PostShare < Share
  
  def self.factory(user, params)
    @new_share = PostShare.new( params )
    @new_share.recipients.each do |rec|
       rec.name = user.name
       rec.address = user.id
    end
    return @new_share
  end
end
