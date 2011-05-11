require "rubygems"
#require "test/spec"
require "selenium"

require "./spec/selenium/ui_model/toolbar"
require "./spec/selenium/ui_model/signin_drawer"
require "./spec/selenium/ui_model/user_homepage"
require "./spec/selenium/ui_model/wizard"
require "./spec/selenium/ui_model/oauth_manager"


module UiModel
  ZZ_HOST = ENV['ZZ_HOST'] || 'zzadmin:sharezzphotos@staging.photos.zangzing.com'

  TEST_USER = {
    :full_name => 'Selenium AutoTest',
    :username => 'selenium_user',
    :password => '123456',
    :email => 'selenium@test.zangzing.com'
  }

  class SeleniumSession
    attr_reader :browser

    attr_reader :toolbar, :user_homepage, :oauth_manager, :wizard

    def wait_for selector
      @browser.wait_for :wait_for => :element, :element => selector
      @browser.wait_for :wait_for => :visible, :element => selector
    end

    def wait_load
      @browser.wait_for_page_to_load "30000"
      #@browser.wait_for "xpath=//body[1]"
      #@browser.wait_for_ajax
    end

    def create_session!
      @timeout = 15
      @browser = Selenium::Client::Driver.new(
        :host => "localhost",
        :port => 4444,
      #	:browser => "*googlechrome", #in chrome does not work ssl
        :browser => "*firefox",
        :url => "http://#{ZZ_HOST}/",
        :timeout_in_seconds => @timeout,
        :javascript_framework => :jquery
      )
      @browser.start_new_browser_session('commandLineFlags' => '--disable-web-security')
      recreate_item_classes!
    end

    def close_session!
      @browser.close_current_browser_session
    end

    def open_site!
      @browser.open "/service"
    end
    
    def timeout
      @timeout
    end
    
    def timeout=(seconds_amount)
      @timeout = seconds_amount
      @browser.remote_control_timeout_in_seconds = seconds_amount
    end
    

 private
    def recreate_item_classes!
      @oauth_manager = OAuthManager.new(self)
      @toolbar = Toolbar.new(self)
      @user_homepage = UserHomepage.new(self)
      @wizard = Wizard::Drawer.new(self)
    end

  end
end
