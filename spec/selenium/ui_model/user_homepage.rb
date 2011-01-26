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
        album_count = @browser.get_xpath_count("//ul[contains(@class, 'albums-grid-view')]/li").to_i
        albums = []
        1.upto(album_count) { |i| albums << @browser.get_text("//ul[contains(@class, 'albums-grid-view')]/li[#{i}]").strip }
        albums
      end

      def inside_album?
        @browser.visible? 'css=body#photos-index.photos'
      end
       
      def current_album_name
        @browser.get_text("css=#album-header-title")
      end

      def click_album(album_name)
        xpath = "xpath=//ul[contains(@class, 'albums-grid-view')]/li/text()[normalize-space(.)='#{album_name}']/..//a"
        @session.wait_for xpath
        @browser.click xpath
        @browser.wait_for_page
      end

      def get_photos_list
        @session.wait_for "//div[@class='photogrid-container']/div[@class='photogrid-cell']"
        photo_count = @browser.get_xpath_count("//div[@class='photogrid-container']/div[@class='photogrid-cell']").to_i
        #photos = []
        #1.upto(photo_count) { |i| photos << @browser.get_text("xpath=(//div[contains(@class, 'photogrid-container')]//div[contains(@class, 'photo-caption')])[#{i}]").strip }
        #photos
        photo_count
      end
  end

end
