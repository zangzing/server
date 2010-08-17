require 'test_helper'
require 'mechanize'
require 'digest'

class TwitterConnectorTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup
    ensure_logged_in
  end

  CREDENTIALS = {:login => 'dev_zangzing', :password => 'share1001photos'}
  
  test "Routing" do
    #Sessions
    assert_routing "/twitter/sessions/new", {:controller => "twitter_sessions", :action => "new"}
    assert_routing "/twitter/sessions/create", {:controller => "twitter_sessions", :action => "create"}
    assert_routing "/twitter/sessions/destroy", {:controller => "twitter_sessions", :action => "destroy"}
    #Posts
    assert_routing "/twitter/posts", {:controller => "twitter_posts", :action => "index"}
    assert_routing "/twitter/posts/create", {:controller => "twitter_posts", :action => "create"}
  end

  @@debug = true
  @@n=0
  def dump_pg(page)
    if @@debug
      puts "#{@@n+=1}) #{page.uri}";
      File.open("E:/tw#{@@n}.htm", 'w') do |f|
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
    visit new_twitter_session_path
    service_auth_url = response.redirected_to
    agent = Mechanize.new { |a| a.user_agent_alias = 'Windows Mozilla' }
    page = agent.get service_auth_url; dump_pg(page)
    agent.follow_meta_refresh = false
    agent.redirect_ok = false
    form = page.forms.first
    form.fields[2].value = CREDENTIALS[:login]
    form.fields[3].value = CREDENTIALS[:password]
    page = form.submit; dump_pg(page)
    create_session_link = page.meta[0].href
    puts "o_O) #{create_session_link}" if @@debug
    visit create_session_link
    puts response.body if @@debug
  end

  def log_out
    visit destroy_twitter_session_path
  end

  #Sessions controller
  test "Log in, test connector functionality, then log out" do
    log_in
    assert_contain "Signed in"

    #Post to a feed
    test_message = "today testing message is #{Digest::SHA1.hexdigest("some randomness - #{DateTime.now.to_s}")}"
    visit create_twitter_post_path, :post, :message => test_message
    visit twitter_posts_path, :get
    assert_contain test_message
    
    log_out
    assert_contain "Signed out"
  end

  #test "Log in using invalid credentials" do
  #  Don't recommend this test because:
  #  Your account has a high number of invalid login attempts.
  #  If you have forgotten your password, {reset your password here}.
  #end

end
