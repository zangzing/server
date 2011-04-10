# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper

 #Return a base title with decorations if any
   def title
     base_title = "ZangZing"
     if @title.nil?
       base_title
     else
       "#{base_title} | #{h(@title)}"
     end
   end

   def password_reset_mailto
      email = "help@zangzing.com"
      subject = "I need help with my password".gsub(' ', '%20')
      return "mailto:#{email}?subject=#{subject}"
   end

   def compatible_browser?

    if browser.safari? && browser.full_version.to_f >= 4
      return true
    elsif browser.firefox? && browser.full_version.to_f >= 3.6
      return true
    elsif browser.ie? && browser.full_version.to_f >= 8
      return true
    elsif browser.chrome? && browser.full_version.to_f >= 9
      return true
    elsif browser.ipad? || browser.ipod? || browser.iphone?
      return true
    end

    return false

   end

   def upgrade_site_for_browser
     if browser.safari?
       return "http://www.apple.com/safari/"
     elsif browser.firefox?
       return "http://www.mozilla.com/"
     elsif browser.ie?
       return "http://www.microsoft.com/ie"
     elsif browser.chrome?
       return "http://chrome.google.com"
     else
       return "http://chrome.google.com"       
     end
   end

   #note: this is duplicated in agent.js
   def add_credentials_to_agent_url(url)
      if url.starts_with? 'http://localhost:30777'
        if ! url.include? '?'
          url += '?'
        end

        url += "session=#{cookies[:user_credentials]}&user_id=#{current_user.id}"

      end

      return url;
   end

   def self.album_pretty_path (username, friendly_id)
     return "/#{username}/#{friendly_id}"
   end


   def album_pretty_url (album, friendly_id = nil)
     friendly_id = friendly_id.nil? ? album.friendly_id : friendly_id
     return "http://#{request.host_with_port}#{ApplicationController.album_pretty_path(album.user.username, friendly_id)}"
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
