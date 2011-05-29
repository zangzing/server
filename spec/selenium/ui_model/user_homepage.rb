module UiModel

  class UserHomepage
      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end

      def inside_album_list?
        @browser.visible? 'css=body#albums-index.albums'
      end

      def get_album_list
        album_count = @browser.get_xpath_count("//div[contains(@class, 'album-cell')]").to_i
        albums = []
        1.upto(album_count) { |i| albums << @browser.get_text("xpath=(//div[@class='caption'])[#{i}]").strip }
        albums
      end

      def inside_album?
        @browser.visible? 'css=body#photos-index.photos'
      end
       
      def current_album_name
        @browser.get_text("css=#album-header-title")
      end

      def click_album(album_name)
        #xpath = "xpath=//div[contains(@class, 'album-name') and contains(text(),'#{album_name}')]/../a"
        css = "css=div#picon-#{album_name.gsub(" ","-")} img.cover-photo"
        @session.wait_for css
        @browser.click css
        @session.wait_load
      end

      def get_photos_list
        @session.wait_for "css=div.photogrid-cell"
        photo_count = @browser.get_xpath_count("//div[@class='photo-caption']").to_i
        photos = []
        1.upto(photo_count) { |i| photos << @browser.get_text("xpath=(//div[@class='photo-caption'])[#{i}]").strip }
        photos
        #photo_count
      end

      def close_welcome_div
         @browser.click "css=a.zz_dialog_closer"
      end
  end

end
