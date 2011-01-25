module UiModel

  class UserHomepage
      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end

      def visible?
        @browser.visible? 'css=body#albums-index.albums'
      end

      def number_of_albums number
        (@browser.get_xpath_count("//li").to_i==number).should be_true
      end

      def get_albums
        number=@browser.get_xpath_count("//td").to_i
        puts "UserHomepage.get_albums = #{number}"
      end
  end

end