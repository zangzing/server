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
        name        = "#{album.name} by #{album.user.username}"
        picture     = album.cover.thumb_url
      when Like::PHOTO, 'photo'
        photo       = Photo.find( like.subject_id )
        name        = "#{photo.caption} by #{photo.user.username}"
        picture     = photo.thumb_url
       when Like::USER, 'user'
        user        = User.find( like.subject_id )
        name        = user.username
        picture     = user.profile_album.cover.thumb_url
      else
        post( like.url, message)  #generic post
        return
    end

    self.facebook_graph.post( "me/feed",                                                 #Where to post
                              :message     => message,                                   #Displayed right under the user's name
                              :picture     => picture,                                   #Displayed in the body of the post
                              :name        => name,                                      #Displayed as a link to link
                              :link        => like.url,                                  #The URL to where the name-link points to
                              :caption     => SystemSetting[:facebook_post_caption],     #Displayed under the name
                              :description => SystemSetting[:facebook_post_description], #Displayed under the name/link/caption combo can be multiline
                              :actions     => SystemSetting[:facebook_post_actions] )
  end

  # Formats share data into a facebook post
  def post_share( share )
    if share.album?
      album       = Album.find( share.subject_id )
      name        = "#{album.name} by #{album.user.username}"
      if album.private?
        picture     = "http://#{Server::Application.config.application_host}/images/private_album.png"
      else
        picture     = album.cover.thumb_url
      end
    elsif share.photo?
      photo       = Photo.find( share.subject_id )
      name        = "#{photo.caption} by #{photo.user.username}"
      if photo.album.private?
        picture     = "http://#{Server::Application.config.application_host}/images/private_photo.png"
      else
        picture     = photo.thumb_url
      end
    else
      post( share.subject_url, share.subject_message )  #generic post
      return
    end
    link        =  share.subject_url

    self.facebook_graph.post( "me/feed",                                                #Where to post
                              :message     => share.message,                            #Displayed right under the user's name
                              :picture     => picture,                                  #Displayed in the body of the post
                              :name        => name,                                     #Displayed as a link to link
                              :link        => link,                                     #The URL to where the name-link points to
                              :caption     => SystemSetting[:facebook_post_caption],    #Displayed under the name
                              :description => SystemSetting[:facebook_post_description],#Displayed under the name/link/caption combo can be multiline
                              :actions     => SystemSetting[:facebook_post_actions] )
  end
end