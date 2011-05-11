module UiModel
  module Wizard

    class Drawer
      attr_reader :add_photos_tab, :album_name_tab, :album_type_tab, :album_contributors_tab, :album_share_tab

        def initialize(selenuim_session)
          @session = selenuim_session
          @browser = selenuim_session.browser

          @add_photos_tab = AddPhotosTab.new(selenuim_session)
          @album_name_tab = AlbumNameTab.new(selenuim_session)
          @album_type_tab = AlbumTypeTab.new(selenuim_session)
          @album_contributors_tab = AlbumContributorsTab.new(selenuim_session)
          @album_share_tab = AlbumShareTab.new(selenuim_session)
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
          @session.wait_for "css=a#submit-new-contributors.green-button"
        end

        def click_share_tab
          @browser.click 'css=#wizard-share'
          @session.wait_for "css=#share-body"
        end

        def click_next_tab
          @browser.click 'css=#next-step'
        end

        def click_done
          @browser.click('css=#wizard-share') unless @browser.visible?('css=#wizard-share')
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

      def agent_not_installed?
        @browser.element?('css=#downloadzz-btn')
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
        total = @browser.get_xpath_count("//figure").to_i
        attr = Array.new
        1.upto(total) { |i| attr[i]=@browser.get_attribute("xpath=(//figure)[#{i}]@onclick") }
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

      def get_album_email
        @browser.key_press("css=#album_name", "\32")
        sleep 4
        @browser.wait_for :wait_for => :ajax
        @browser.get_value('css=#album_email').strip
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
    
    
    
    
    class AlbumContributorsTab
      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end

      def visible?
        (@browser.element?('css=#contributor-index') && @browser.visible?('css=#contributor-index')) || (@browser.element?('css=#new_contributors-index') && @browser.visible?('css=#new_contributors-index'))
      end
      
      def import_gmail_contacts
        @browser.click "css=img#gmail-sync.link"
        @browser.select_window "oauthlogin" #select the oauth sign in window
        @session.wait_for 'css=input#Email.gaia.le.val'
        @browser.type "Email", "dev.zangzing@gmail.com"
        @browser.type "Passwd", "share1001photos"
        @browser.click "signIn"
        #@session.wait_load
        @session.wait_for 'css=input#allow'
        @browser.click 'css=input#allow'
        @browser.select_window "null"
        sleep 5
      end
      
      def import_yahoo_contacts
        @browser.click "css=img#yahoo-sync.link"
        @browser.select_window "name=oauthlogin"
        @session.wait_load
        @browser.type "username", "zangzing_dev"
        @browser.type "passwd", "clev-vid-arch-ab-a"
        @browser.click ".save"
        @session.wait_load
        @browser.click "agree"
        @browser.select_window "null"
        sleep 5
      end
      
      def import_mslive_contacts
        @browser.click "css=img#mslive-sync.link"
        @browser.select_window "name=oauthlogin"
        @session.wait_load
        @browser.click "i0116"
        sleep 1
        @browser.type "i0116", "dev_zangzing@hotmail.com"
        @browser.type "i0118", "QaVH6kP6XdMPzLTz"
        @browser.click "css=input#idSIButton9"
        sleep 5
        #@browser.select_pop_up('')
        #@session.wait_load
        #@browser.click "Continue"
        #@browser.click "ctl00_MainContent_ConsentBtn"
        @browser.select_window "null"
      end

      # Only on Windows and OSX #########################################################################################
      def import_outlook_contacts
        @browser.click "css=img#local-sync.link"
        sleep 5
      end


      def imported_gmail?
        @browser.is_element_present("//img[@src='/images/btn-gmail-on.png']")
      end
      
      def imported_yahoo?
        @browser.is_element_present("//img[@src='/images/btn-yahoo-on.png']")
      end
      
      def imported_mslive?
        @browser.is_element_present("//img[@src='/images/btn-mslive-on.png']")
      end

      def imported_outlook?
        @browser.is_element_present("//img[@src='/images/btn-outlook-on.png']")
      end
      
      def add_contributors(emails)
        [emails].flatten.each do |email|
            @browser.type("css=input#you-complete-me.ac_input", email)
            @browser.key_down("css=input#you-complete-me.ac_input", '\13')
            @browser.key_up("css=input#you-complete-me.ac_input", '\13')
        end
        @browser.type "css=textarea#email_share_message", "Hi, now you contributor of my album!"
        @browser.click "css=a#submit-new-contributors.green-button"
        #@session.wait_for "css=a#add-contributors-btn.green-add-button"
      end
      
    end

    class AlbumShareTab
      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end
      
      def click_share_by_email
        @browser.click "css=li.email-share.link"
        @session.wait_for "css=input#you-complete-me.ac_input"
      end
      
      
      def click_share_by_social
        @browser.click "css=li.social-share.link"
        @session.wait_for "css=textarea#post_share_message"
      end
      
      def click_facebook
        @browser.click "css=input#facebook_box"
        @browser.select_window "oauthlogin" #select the oauth sign in window
        @session.wait_for "css=#email"
        @browser.type "css=#email", "jeremy@zangzing.com"
        @browser.type "css=#pass", "share1001photos"
        @browser.click "css=input[name=login]"
        sleep 5
        @browser.select_window "null" #select the main window
      end
      
      def click_twitter
        @browser.click "css=input#twitter_box"
        @browser.select_window "name=oauthlogin"
        @session.wait_load
        @browser.type "username_or_email", "jeremy@zangzing.com"
        @browser.type "password", "share1001photos"
        @browser.click "allow"
        @browser.select_window "null"
      end
        
      def type_emails(emails)
        @browser.click "css=input#you-complete-me.ac_input"
        [emails].flatten.each do |email|
            @browser.type("css=input#you-complete-me.ac_input", email)
            @browser.key_down("css=input#you-complete-me.ac_input", '\13')
            @browser.key_up("css=input#you-complete-me.ac_input", '\13')
        end
        @browser.type "css=textarea#email_share_message", "Hi, see my new album!!!!"
        @browser.click "css=a#mail-submit.green-button"
        @session.wait_for "css=li.email-share.link"
      end  
      
      def send_message
        @session.wait_for "css=textarea#post_share_message"
        @browser.type "css=textarea#post_share_message", "Hi, see my new album!"
        sleep 5
        @browser.click "css=a#post_share_button.green-button"
        @session.wait_for "css=li.social-share.link"
      end
      
      
    end

  end
end
