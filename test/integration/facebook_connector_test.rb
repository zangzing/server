require 'test_helper'
require 'mechanize'
require 'digest'

class FacebookConnectorTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup
    ensure_logged_in
  end

  CREDENTIALS = {:login => 'dev@zangzing.com', :password => 'share1001photos'}
  
  test "Routing" do
    #Sessions
    assert_routing "/facebook/sessions/new", {:controller => "facebook_sessions", :action => "new"}
    assert_routing "/facebook/sessions/create", {:controller => "facebook_sessions", :action => "create"}
    assert_routing "/facebook/sessions/destroy", {:controller => "facebook_sessions", :action => "destroy"}
    #Folders
    assert_routing "/facebook/folders", {:controller => "facebook_folders", :action => "index"}
    assert_routing "/facebook/folders/456/import", {:controller => "facebook_folders", :action => "import", :fb_album_id => '456'}
    #Photos
    assert_routing "/facebook/folders/123/photos", {:controller => "facebook_photos", :action => "index", :fb_album_id => "123"}
#    assert_routing "/facebook/folders/123/photos/456.screen", {:controller => "facebook_photos", :action => "show", :fb_album_id => "123", :photo_id => "456", :size => 'screen'}
    assert_routing "/facebook/folders/123/photos/456/import", {:controller => "facebook_photos", :action => "import", :fb_album_id => "123", :photo_id => "456"}
  end

  @@debug = false
  @@n=0
  def dump_pg(page)
    if @@debug
      puts "#{@@n+=1}) #{page.uri}";
      File.open("E:/p#{@@n}.htm", 'w') do |f|
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
    visit new_facebook_session_path
    service_auth_url = response.redirected_to
    agent = Mechanize.new { |a| a.user_agent_alias = 'Windows Mozilla' }
    page = agent.get service_auth_url; dump_pg(page)
    agent.follow_meta_refresh = false
    agent.redirect_ok = false
    begin
      form = page.forms.first
      form.email = CREDENTIALS[:login]
      form.pass = CREDENTIALS[:password]
      page = form.submit
      dump_pg(page)
      #begin
    end while page.header['location'].blank? && @@n<5
    page = agent.get page.header['location']; dump_pg(page)
    page = agent.get page.header['location']; dump_pg(page)
    create_session_link = page.header['location']
    puts "o_O) #{create_session_link}" if @@debug
    code = URI.decode(create_session_link.match(/code=(.+)/).to_a.last)
    puts "CODE=#{code}" if @@debug
    visit "http://#{Server::Application.config.application_host}/facebook/sessions/create?code=#{URI.encode(code)}"
    #visit new_facebook_session_url(:host => Server::Application.config.application_host, :code => URI.encode(code))
    puts response.body if @@debug
    #puts "TOKEN=====> #{session[:facebook][77]}" if @@debug
  end

  def log_out
    visit destroy_facebook_session_url
  end

  #Sessions controller
  test "Log in, test connector functionality, then log out" do
    log_in
    assert_contain "Signed in"

    # "Get photoset list (HTML)" do
    visit facebook_folders_url
    assert_contain "Test Album 01"
    assert_contain "Album_1"
    assert_contain "Album_2"

    # "Get photoset list (JSON)" do
    visit facebook_folders_url(:format => 'json')
    result = JSON.parse response.body
    assert result.size == 3
    assert result[0]['name'] == 'Test Album 01'

    # "Import whole photoset (JSON)" do
    visit facebook_folder_action_url(:fb_album_id => 115847311797751, :action => :import, :format => :json, :album_id => 1)
    result = JSON.parse response.body
    result.each do |r|
      assert r['caption'] =~ /dlink .+/
    end

    #Photos controller
    # "Get photos list from 1st photoset" do
    visit facebook_photos_url(:fb_album_id => 115847311797751)
    assert_contain "dlink general view"
    assert_contain "dlink box contents"
    assert_contain "dlink back"
    assert_contain "dlink face"

    # "Get photos list from 2nd photoset" do
    visit facebook_photos_url(:fb_album_id => 113331162049366)
    assert_contain "113331218716027"
    assert_contain "113331215382694"
    assert_contain "113331212049361"


# commented out because we no longe support image proxy
#    # "Get photo thumbnail from 1st photoset" do
#    visit facebook_photo_url(:fb_album_id => 115847311797751, :photo_id => 115847788464370, :size => :thumb)
#    assert response['Content-Type'] =~ /image\/.+/
#
#    # "Get photo thumbnail from 2nd photoset" do
#    visit facebook_photo_url(:fb_album_id => 113331162049366, :photo_id => 113331215382694, :size => :thumb)
#    assert response['Content-Type'] =~ /image\/.+/

    # "Import photo from a photoset (JSON)" do
    visit facebook_photo_action_url(:fb_album_id => 115847311797751, :photo_id => 115847785131037, :action => :import, :format => :json, :album_id => 1)
    result = JSON.parse(response.body)
    assert result['caption'] =~ /dlink .+/

    #Post to a feed
    test_message = "today testing message is #{Digest::SHA1.hexdigest("some randomness - #{DateTime.now.to_s}")}"
    visit create_facebook_post_path, :post, :message => test_message
    visit facebook_posts_path, :get
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
