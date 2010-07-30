require 'test_helper'
require 'mechanize'

class FacebookConnectorTest < ActionController::IntegrationTest
  #fixtures :all
  CREDENTIALS = {:login => 'dev@zangzing.com', :password => 'share1001photos'}
  @@logged_in = false

  def setup
    log_in
  end

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
    assert_routing "/facebook/folders/123/photos/456.screen", {:controller => "facebook_photos", :action => "show", :fb_album_id => "123", :photo_id => "456", :size => 'screen'}
    assert_routing "/facebook/folders/123/photos/456/import", {:controller => "facebook_photos", :action => "import", :fb_album_id => "123", :photo_id => "456"}
  end


  def log_in
      visit new_facebook_session_url
      facebook_signin_url = response.redirected_to



      agent = Mechanize.new { |a| a.user_agent_alias = 'Windows Mozilla' }
      page = agent.get facebook_signin_url
      form = page.forms.first
      form.email = CREDENTIALS[:login]
      form.pass = CREDENTIALS[:password]
      agent.follow_meta_refresh = false
      agent.redirect_ok = false
      page = form.submit
      i=0
      puts "#{i+=1}) #{page.uri}"
      #begin
        page = agent.get page.header['location']
      puts "#{i+=1}) #{page.uri}"
        page = agent.get page.header['location']
      puts "#{i+=1}) #{page.uri}"
        create_session_link = page.header['location']
      puts "o_O) #{create_session_link}"
        code = URI.decode(create_session_link.match(/code=(.+)/).to_a.last)
      #rescue
      #  code = 'bobiki_i_kiski'
      #end
      puts "CODE=#{code}"
      agent.cookies.each { |ac| cookies[ac.name] = ac.value }
      #visit create_session_link
      visit create_facebook_session_url(:code => code)
      puts cookies.inspect
      puts response.body

=begin
      #@@logged_in = true
      @@token = session[:facebook][77]
      puts "SESSION+: #{session.inspect} / #{response.body}"
    else
      visit new_facebook_session_url
      session[:facebook] = {77 => '112996675412403|2.TEgDckzwOBYIC8G1L_DcxQ__.3600.1280419200-100001174482639|rWPdP40J_dnKmmCV4YMpW-RmUgc.'}
      puts "SESSION-: #{session.inspect} / #{response.body}"
    end
    puts "TOKEN=====> #{session[:facebook][77]}"
=end  
  end

  def log_out
    visit destroy_facebook_session_url
  end

  #Sessions controller
  test "Log in using correct credentials and log out" do
    #log_in
    assert_contain "Signed in"
    log_out
    assert_contain "Signed out"
  end

  #test "Log in using invalid credentials" do
  #  Don't recommend this test because:
  #  Your account has a high number of invalid login attempts.
  #  If you have forgotten your password, {reset your password here}.
  #end

  #Folders controller
  test "Get photoset list (HTML)" do
    #log_in
    visit facebook_folders_url
    assert_contain "Test Album 01"
    assert_contain "Album_1"
    assert_contain "Album_2"
    log_out
  end
=begin
  test "Get photoset list (JSON)" do
    #log_in
    visit facebook_folders_url(:format => 'json')
    result = JSON.parse response.body
    assert result.size == 3
    assert result[0]['name'] = 'Test Album 01'
    log_out
  end

  test "Import whole photoset (JSON)" do
    #log_in
    visit facebook_folder_action_url(:fb_album_id => 115847311797751, :action => :import, :format => :json)
    result = JSON.parse response.body
    result.each do |r|
      assert r['photo']['title'] =~ /dlink .+/
    end
    log_out
  end

  #Photos controller
  test "Get photos list from 1st photoset" do
    #log_in
    visit facebook_photos_url(:fb_album_id => 115847311797751)
    assert_contain "dlink general view"
    assert_contain "dlink box contents"
    assert_contain "dlink back"
    assert_contain "dlink face"
    log_out
  end

  test "Get photos list from 2nd photoset" do
    #log_in
    visit facebook_photos_url(:fb_album_id => 113331162049366)
    assert_contain "ID#113331218716027"
    assert_contain "ID#113331215382694"
    assert_contain "ID#113331212049361"
    log_out
  end

  test "Get photo thumbnail from 1st photoset" do
    #log_in
    visit facebook_photo_url(:fb_album_id => 115847311797751, :photo_id => 115847788464370, :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/
    log_out
  end

  test "Get photo thumbnail from 2nd photoset" do
    #log_in
    visit facebook_photo_url(:fb_album_id => 113331162049366, :photo_id => 113331215382694, :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/
    log_out
  end

  test "Import photo from a photoset (JSON)" do
    #log_in
    visit facebook_photo_action_url(:fb_album_id => 115847311797751, :photo_id => 115847785131037, :action => :import, :format => :json)
    result = JSON.parse response.body
    assert result['photo']['title'] =~ /dlink .+/
    log_out
  end
=end
end
