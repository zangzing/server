#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class FacebookIdentity < Identity


  def facebook_graph
    raise InvalidToken unless self.valid?
    begin
      @graph ||= HyperGraph.new(self.credentials)
    rescue => exception
       raise InvalidToken if exception.kind_of?(FacebookError)
       raise HttpCallFail if exception.kind_of?(SocketError)
    end
  end

  def facebook_graph=(val)
    @graph = val
  end

  def facebook_auth_token
    self.credentials
  end
end