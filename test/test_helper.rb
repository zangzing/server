ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do |session|
    session.host! Server::Application.config.application_host
  end

end

Webrat.configure do |config|
  config.mode = :rails
end

module IntegrationHelper
  TEST_USER_CREDENTIALS = {:email => 'test@user.org', :password => '123456'}
  @@logged_in = false

  def ensure_logged_in
    visit root_path
    unless response.body.include?('Sign out')
      visit user_sessions_path, :post, :user_session => {:email => TEST_USER_CREDENTIALS[:email], :password => TEST_USER_CREDENTIALS[:password], :remember_me => true}
      if response.body.include?('<div class="fieldWithErrors"><label for="user_session_email">') #Unsuccessful login
        visit users_path, :post, :user => {:name => 'TestUser', :email => TEST_USER_CREDENTIALS[:email], :password => TEST_USER_CREDENTIALS[:password], :password_confirmation => TEST_USER_CREDENTIALS[:password] }
        @@logged_in = response.body.include?('You are being') #redirected to user#show
        visit user_path(:user_id => 1), :post, :album => {:user_id => 1, :name => 'Test Album'}
      end
    end
  end

  def copy_cookies_to_mechanize(agent)
    #puts cookies.inspect
    cookies.each do |n, v|
      #puts "N ==== #{n}    V ===== #{v}"
      c = Mechanize::Cookie.new(n, v)
      c.domain = 'localhost'
      c.path = '/'
      agent.cookie_jar.add URI.parse("http://#{Server::Application.config.application_host}/"), c
    end
    #puts agent.cookies.inspect
  end
end