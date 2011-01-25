module UiModel
  module Wizard

    class Drawer
      attr_reader :add_photos_tab, :album_name_tab, :album_type_tab

        def initialize(selenuim_session)
          @session = selenuim_session
          @browser = selenuim_session.browser

          @add_photos_tab = AddPhotosTab.new(selenuim_session)
          @album_name_tab = AlbumNameTab.new(selenuim_session)
          @album_type_tab = AlbumTypeTab.new(selenuim_session)
        end

        def click_name_tab
          @browser.click 'css=#wizard-name'
          @session.wait_for "css=#album_name"
        end

        def click_edit_tab
        end

        def click_privacy_tab
          @browser.click 'css=#wizard-privacy'
          @session.wait_for "css=#album_name""css=#privacy-public"
        end

        def click_contributors_tab
          @browser.click 'css=#wizard-contributors'
          @session.wait_for "css=#add-contributors-btn"
        end

        def click_share_tab
          @browser.click 'css=#wizard-share'
        end

        def click_next_tab
          @browser.click 'css=#next-step'
        end

        def click_done
          @browser.click 'css=#wizard-share'
          @browser.click 'css=#next-step'
        end

    end

    class AddPhotosTab
      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end

      def visible?
        @browser.visible? 'css=#wizard-add'
      end

      def back_level_up
        @browser.click 'css=#filechooser-back-button'
        @browser.wait_for_ajax
      end

      def at_home?
        @browser.get_text('css=#filechooser-title')=='Home'
      end

      def go_home
        until at_home? do
          back_level_up
        end
      end

      def click_folder foldername
        @session.wait_for "css=a:contains(#{foldername})"
        @browser.click "css=a:contains(#{foldername})"
        @browser.wait_for_ajax
      end

      def add_photo
        @session.wait_for "css=#filechooser .photo"
        @browser.click 'css=.filechooser.photo figure'
        sleep 1 #wait for animation
        @browser.wait_for  :wait_for => :ajax
      end

      def add_all_folder folder
        @session.wait_for "css=a:contains(#{folder}) + a"
        @browser.click "css=a:contains(#{folder}) + a"
        sleep 1 #wait for animation
        @browser.wait_for :wait_for => :ajax
      end

      def add_random_photos(amount = 1)
        @session.wait_for "css=#filechooser .photo"
        total = @browser.get_xpath_count("//figure").to_i #//div[@class='photogrid-cell']
        puts "TOTAL=#{total}"
        attr = Array.new
        1.upto(total) { |i| attr[i]=@browser.get_attribute("xpath=(//figure)[#{i}]@onclick") }
        puts "ATTR=#{attr.inspect}"
        amount.times { @browser.click "//figure[@onclick=\"#{attr[rand(total)+1]}\"]" }
      end
    end

    class AlbumNameTab
      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end

      def visible?
        @browser.visible? 'css=#wizard-name'
      end

      def type_album_name album
        @browser.type "css=#album_name", album
      end
    end

    class AlbumTypeTab
      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end

      def visible?
        @browser.visible?('css=#tab-content #headline') && @browser.get_text('css=#drawer-tabs').strip.empty?
      end

      def click_group_album
        @browser.click "css=#group_album_link"
        @session.wait_for 'css=a:contains("Facebook")'
      end

      def click_personal_album
        @browser.click "css=#personal_album_link"
        @session.wait_for 'css=a:contains("Facebook")'
      end

    end

  end
end