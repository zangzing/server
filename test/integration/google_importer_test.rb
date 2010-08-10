require 'test_helper'
require 'mechanize'

class GoogleContactsImporterTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup
    ensure_logged_in
  end


  CREDENTIALS = {:login => 'dev.zangzing@gmail.com', :password => 'share1001photos'}
  
  test "Routing" do
    #Sessions
    assert_routing "/google/sessions/new", {:controller => "google_sessions", :action => "new"}
    assert_routing "/google/sessions/create", {:controller => "google_sessions", :action => "create"}
    assert_routing "/google/sessions/destroy", {:controller => "google_sessions", :action => "destroy"}
    #Contact import
    assert_routing "/google/contacts", {:controller => "google_contacts", :action => "index"}
    assert_routing "/google/contacts/import", {:controller => "google_contacts", :action => "import"}
  end

  @@debug = false
  @@n=0
  def dump_pg(page)
    if @@debug
      puts "#{@@n+=1}) #{page.uri}";
      File.open("E:/goo#{@@n}.htm", 'w') do |f|
        f.write "#{page.uri.to_s}\n\n"
        page.header.each do |n,v|
          f.write "[#{n}=#{v}]\n"
        end
        f.write "\n\n"
        f.write page.body
      end
    end
  end

  def log_in
    visit new_google_session_path
    service_auth_url = response.redirected_to
    puts "#{@@n+=1}) #{service_auth_url}" if @@debug
    agent = Mechanize.new { |a| a.user_agent_alias = 'Windows Mozilla' }
    page = agent.get service_auth_url; dump_pg(page)
    form = page.forms.first
    form.Email = CREDENTIALS[:login]
    form.Passwd = CREDENTIALS[:password]
    agent.follow_meta_refresh = false
    agent.redirect_ok = false
    page = form.submit; dump_pg(page)
    page = agent.get page.header['location']; dump_pg(page)
    page = agent.get page.meta[0].href; dump_pg(page)
    page = agent.get page.header['location'];  dump_pg(page)
    form = page.forms.first
    accept_btn = form.buttons.select{|b| b.name='allow'}.first
    page = agent.submit form, accept_btn
    create_session_link = page.header['location']
    puts "o_O) #{create_session_link}" if @@debug
    visit create_session_link
    puts response.body if @@debug
  end

  def log_out
    visit destroy_google_session_url
  end

  #Sessions controller
  test "Log in, test connector functionality, then log out" do
    log_in
    assert_contain "Signed in"

    # "Imoprt contacts" do
    visit google_contacts_path(:action => 'import')
    visit google_contacts_path
    assert_contain "mauricio@zangzing.com"
    assert_contain "vivtash.oleg@archer-soft.com"
    assert_contain "jeremy@zangzing.com"

    log_out
    assert_contain "Signed out"
  end

end