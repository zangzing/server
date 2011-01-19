require "rubygems"
require "test/spec"
require "selenium"

require "spec/selenium/ui_model/toolbar"
require "spec/selenium/ui_model/signin_drawer"
require "spec/selenium/ui_model/user_homepage"
require "spec/selenium/ui_model/wizard"
require "spec/selenium/ui_model/oauth_manager"

module UiModel

  class SeleniumSession
    attr_accessor :browser

    attr_reader :toolbar, :user_homepage, :oauth_manager, :signin_drawer_signin_tab,
                :signin_drawer_join_tab, :wizard_drawer,
                :wizard_add_photos_tab, :wizard_album_name_tab, :wizard_album_type_tab

    def wait_for selector
      @browser.wait_for :wait_for => :element, :element => selector
      @browser.wait_for :wait_for => :visible, :element => selector
    end

    def wait_load
      @browser.wait_for_page_to_load "30000"
    end

    def create_session!
      @browser = Selenium::Client::Driver.new(
        :host => "localhost",
        :port => 4444,
      #	:browser => "*googlechrome", #in chrome does not work ssl
        :browser => "*firefox",
        :url => "http://zzadmin:sharezzphotos@share1001photos.zangzing.com/",
        :timeout_in_second => 60,
        :javascript_framework => :jquery
      )
      @browser.start_new_browser_session('commandLineFlags' => '--disable-web-security')
      recreate_item_classes!
    end

    def close_session!
      @browser.close_current_browser_session
    end

    def open_site!
      @browser.open "/"
    end

private
    def recreate_item_classes!
      @oauth_manager = OAuthManager.new(self)
      @signin_drawer_join_tab = SigninDrawer::JoinTab.new(self)
      @signin_drawer_signin_tab = SigninDrawer::SigninTab.new(self)
      @toolbar = Toolbar.new(self)
      @user_homepage = UserHomepage.new(self)
      @wizard_drawer = Wizard::Drawer.new(self)
      @wizard_add_photos_tab = Wizard::AddPhotosTab.new(self)
      @wizard_album_name_tab = Wizard::AlbumNameTab.new(self)
      @wizard_album_type_tab = Wizard::AlbumTypeTab.new(self)
    end

  end
end