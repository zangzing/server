module UiModel

  class OAuthManager
    attr_reader :browser

      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end

      def login_to_facebook
        @session.wait_for "css=img[src='/images/service-connect-button.jpg']" #todo: need better css selector for this
        @browser.click "css=img[src='/images/service-connect-button.jpg']"
        @browser.select_window "oauthlogin" #select the oauth sign in window
        sleep 20
        @session.wait_for "css=#email"
        @browser.type "css=#email", "jeremy@zangzing.com"
        @browser.type "css=#pass", "share1001photos"
        @browser.click "css=input[name=login]"
        @browser.select_window "null" #select the main window
        #wait 'My Albums'
        @session.wait_for 'css=a:contains("My Albums")'
        @browser.click 'css=a:contains("My Albums")'
        #wait "Medium Album'
        @session.wait_for 'css=a:contains("Medium Album")'
      end

      def login_to_shutterfly
        @session.wait_for "css=img[src='/images/service-connect-button.jpg']" #todo: need better css selector for this
        @browser.click "css=img[src='/images/service-connect-button.jpg']"
        @browser.select_window "oauthlogin" #select the oauth sign in window
        #sleep 20
        #wait_for "css=#waitWheel"
        @session.wait_load
        @browser.click "link=Sign in."
        #wait_load
        @browser.type "css=#userName", "dev@zangzing.com"
        @browser.type "css=#password", "share1001"
        @browser.click "css=#signInButton"
        @browser.select_window "null" #select the main window
        @session.wait_for 'css=a:contains("Medium Album")'
      end


      def login_to_kodak
        @session.wait_for "css=img[src='/images/service-connect-button.jpg']" #todo: need better css selector for this
        @browser.click "css=img[src='/images/service-connect-button.jpg']"
        @browser.select_window "oauthlogin" #select the oauth sign in window
        #sleep 20
        #wait_for "css=#waitWheel"
        #wait_load
        @browser.type "email", "dev@zangzing.com "
        @browser.type "password", "ijertyewij"
        @browser.click "commit"
        @browser.select_window "null" #select the main window
        @session.wait_for 'css=a:contains("Medium Album")'
      end


      def login_to_smugmug
        @session.wait_for "css=img[src='/images/service-connect-button.jpg']" #todo: need better css selector for this
        @browser.click "css=img[src='/images/service-connect-button.jpg']"
        @browser.select_window "oauthlogin" #select the oauth sign in window
        #sleep 20
        #wait_for "css=#waitWheel"
        #wait_load
        @browser.type "Email", "dev@zangzing.com"
        @browser.type "Password", "share1001photos"
        @browser.click "//input[@value='' and @type='image']"
        @browser.select_window "null" #select the main window
        @session.wait_for 'css=a:contains("Medium Album")'
      end


      def login_to_flickr
        @session.wait_for "css=img[src='/images/service-connect-button.jpg']" #todo: need better css selector for this
        @browser.click "css=img[src='/images/service-connect-button.jpg']"
        @browser.select_window "oauthlogin" #select the oauth sign in window
        #sleep 20
        #wait_for "css=#waitWheel"
        #wait_load
        @browser.type "css=#username", "zangzing_dev"
        @browser.type "css=#passwd", "clev-vid-arch-ab-a"
        @browser.click ".save"
        @browser.select_window "null" #select the main window
        @session.wait_for 'css=a:contains("Medium Album")'
      end


      def login_to_picasa
        @session.wait_for "css=img[src='/images/service-connect-button.jpg']" #todo: need better css selector for this
        @browser.click "css=img[src='/images/service-connect-button.jpg']"
        @browser.select_window "oauthlogin" #select the oauth sign in window
        #sleep 20
        #wait_for "css=#waitWheel"
        #wait_load
        @browser.type "Email", "dev.zangzing@gmail.com"
        @browser.type "Passwd", "share1001photos"
        @browser.click "signIn"
        @session.wait_load
        @browser.click "allow"
        @browser.select_window "null" #select the main window
        @session.wait_for 'css=a:contains("MediumAlbum")'
      end


      def login_to_photobucket
        wait_for "css=img[src='/images/service-connect-button.jpg']" #todo: need better css selector for this
        @browser.click "css=img[src='/images/service-connect-button.jpg']"
        @browser.select_window "oauthlogin" #select the oauth sign in window
        #sleep 20
        #wait_for "css=#waitWheel"
        #wait_load
        @browser.type "usernameemail", "dev@zangzing.com"
        @browser.type "password", "share1001photos"
        @browser.click "login"
        @browser.select_window "null" #select the main window
        wait_for 'css=a:contains("Medium Album")'
      end

  end

end