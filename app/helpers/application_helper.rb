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

end
