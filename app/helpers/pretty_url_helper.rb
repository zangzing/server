module PrettyUrlHelper
   def album_pretty_path(username, friendly_id)
     return "/#{username}/#{friendly_id}"
   end

   def album_pretty_url(album, friendly_id = nil)
     friendly_id = friendly_id.nil? ? album.friendly_id : friendly_id
     return "http://#{Server::Application.config.application_host}#{album_pretty_path(album.user.username, friendly_id)}"
   end

   def album_activities_pretty_url( album )
     "#{album_pretty_url( album )}/activities"
   end

   def photo_pretty_url(photo)
     "#{user_url( photo.album.user)}/#{photo.album.friendly_id}/photos/#!#{photo.id}"
   end

   def photo_url(photo)
      album_photos(photo.album) + "/#!{photo.id}"
   end

   def user_pretty_url(user)
     user_url( user )
   end
end