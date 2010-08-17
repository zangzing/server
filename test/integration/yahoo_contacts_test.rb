require 'test_helper'

class YahooContactsTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup
    ensure_logged_in
  end

  CREDENTIALS = {:email => 'zangzing_dev', :password => 'clev-vid-arch-ab-a'}

  test "Routing" do
    #Sessions
    assert_routing "/yahoo/sessions/new", {:controller => "yahoo_sessions", :action => "new"}
    assert_routing "/yahoo/sessions/create", {:controller => "yahoo_sessions", :action => "create"}
    assert_routing "/yahoo/sessions/destroy", {:controller => "yahoo_sessions", :action => "destroy"}
    #Contact import
    assert_routing "/yahoo/contacts", {:controller => "yahoo_contacts", :action => "index"}
    assert_routing "/yahoo/contacts/import", {:controller => "yahoo_contacts", :action => "import"}
  end

  def log_in(valid_credentials = true)
    #visit new_yahoo_session_path
    #fill_in "login", :with => valid_credentials ? CREDENTIALS[:email] : 'foo'
    #ill_in "password", :with => valid_credentials ? CREDENTIALS[:password] : 'bar'
    #click_button 'Log in'
    creds = {:login => valid_credentials ? CREDENTIALS[:email] : 'foo', :password => valid_credentials ? CREDENTIALS[:password] : 'bar'}
    visit create_yahoo_session_path, :post, creds
  end

  def log_out
    visit destroy_yahoo_session_url
  end
  
  test "Log in using correct credentials, test connector, log out" do
    log_in(true)
    assert_contain "Signed in"
    
    # "Imoprt contacts" do
    visit yahoo_contacts_path(:action => 'import')
    visit yahoo_contacts_path
    assert_contain "burton@fearfactory.com"
    assert_contain "wayne@static-x.com"
    assert_contain "corey@slipknot1.com"

    log_out
    assert_contain "Signed out"
  end

  test "Log in using invalid credentials" do
    log_in(false)
    assert status==401
  end
  
end
