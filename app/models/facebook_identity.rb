#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class FacebookIdentity < Identity

  def facebook_graph
    unless @graph
      raise InvalidToken unless self.credentials
      begin
        @graph = HyperGraph.new(self.credentials)
      rescue => exception
       raise InvalidToken if exception.kind_of?(FacebookError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
      raise InvalidToken unless @graph
    end    
    return @graph
  end

   def post( message="" )
     self.facebook_graph.post("me/feed", :message => message)
   end

  def facebook_auth_token
    self.credentials
  end

end