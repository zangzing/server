#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class FacebookIdentity < Identity

  DEFAULT_CAPTION = "www.zangzing.com  -  Group Photo Sharing"
  DEFAULT_ACTIONS = {"name" => "Join ZangZing", "link" => "http://www.zangzing.com/join"}.to_json

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

  def facebook_auth_token
    self.credentials
  end

  def post(link, message = '')
    self.facebook_graph.post("me/feed", :message => message, :link => link)
  end

  def post_like(like, message)
    case like.subject_type
      when Like::ALBUM, 'album'
        album       = Album.find( like.subject_id )
        action      = "#{user.username} likes a ZangZing Photo Album"
        name        = "#{album.name} by #{album.user.username}"
        picture     = album.cover.thumb_url
      when Like::PHOTO, 'photo'
        photo       = Photo.find( like.subject_id )
        action      = "#{user.username} likes a ZangZing Photo"
        name        = "#{photo.caption} by #{photo.user.username}"
        picture     = photo.thumb_url
      else
        post( like.url, message)  #generic post
        return
    end

    self.facebook_graph.post( "me/feed",                       #Where to post
                              :message     => action,          #Displayed right under the user's name
                              :picture     => picture,         #Displayed in the body of the post
                              :name        => name,            #Displayed as a link to link
                              :link        => like.url,        #The URL to where the name-link points to
                              :caption     => DEFAULT_CAPTION, #Displayed under the name
                              :description => message,         #Displayed under the name/link/caption combo can be multiline
                              :actions     => DEFAULT_ACTIONS  )
  end

  # Formats share data into a facebook post
  def post_share( share )
    if share.album?
      album       = Album.find( share.subject_id )
      message     = "#{user.username} shared a ZangZing Photo Album"
      name        = "#{album.name} by #{album.user.username}"
      picture     = album.cover.thumb_url
    elsif share.photo?
      photo       = Photo.find( share.subject_id )
      message     = "#{user.username} shared a ZangZing Photo"
      name        = "#{photo.caption} by #{photo.user.username}"
      picture     = photo.thumb_url
    else
      post( share.subject_url, share.subject_message )  #generic post
      return
    end
    link        =  share.subject_url
    description =  share.message
    
    self.facebook_graph.post( "me/feed",                       #Where to post
                              :message     => message,         #Displayed right under the user's name
                              :picture     => picture,         #Displayed in the body of the post
                              :name        => name,            #Displayed as a link to link
                              :link        => link,            #The URL to where the name-link points to
                              :caption     => DEFAULT_CAPTION, #Displayed under the name
                              :description => description,     #Displayed under the name/link/caption combo can be multiline
                              :actions     => DEFAULT_ACTIONS )
  end
end