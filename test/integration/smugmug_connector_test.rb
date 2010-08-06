require 'test_helper'
require 'mechanize'

class SmugmugConnectorTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup
    ensure_logged_in
  end


  CREDENTIALS = {:login => 'dev@zangzing.com', :password => 'share1001photos'}
  
  test "Routing" do
    #Sessions
    assert_routing "/smugmug/sessions/new", {:controller => "smugmug_sessions", :action => "new"}
    assert_routing "/smugmug/sessions/create", {:controller => "smugmug_sessions", :action => "create"}
    assert_routing "/smugmug/sessions/destroy", {:controller => "smugmug_sessions", :action => "destroy"}
    #Folders
    assert_routing "/smugmug/folders", {:controller => "smugmug_folders", :action => "index"}
    assert_routing "/smugmug/folders/456/import", {:controller => "smugmug_folders", :action => "import", :sm_album_id => '456'}
    #Photos
    assert_routing "/smugmug/folders/123/photos", {:controller => "smugmug_photos", :action => "index", :sm_album_id => "123"}
    assert_routing "/smugmug/folders/123/photos/456.screen", {:controller => "smugmug_photos", :action => "show", :sm_album_id => "123", :photo_id => "456", :size => 'screen'}
    assert_routing "/smugmug/folders/123/photos/456/import", {:controller => "smugmug_photos", :action => "import", :sm_album_id => "123", :photo_id => "456"}
  end

  @@debug = false
  @@n=0
  def dump_pg(page)
    if @@debug
      puts "#{@@n+=1}) #{page.uri}";
      File.open("E:/sm#{@@n}.htm", 'w') do |f|
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
    visit new_smugmug_session_path
    service_auth_url = response.redirected_to
    agent = Mechanize.new { |a| a.user_agent_alias = 'Windows Mozilla' }
    page = agent.get service_auth_url; dump_pg(page)
    agent.follow_meta_refresh = false
    agent.redirect_ok = false
    form = page.forms.last
    form.username = CREDENTIALS[:login]
    form.password = CREDENTIALS[:password]
    page = form.submit
    dump_pg(page)
    page = agent.get page.meta[0].href; dump_pg(page)
    create_session_link = page.header['location']
    puts "o_O) #{create_session_link}" if @@debug
    visit create_session_link
    puts response.body if @@debug
    puts "TOKEN=====> #{session[:smugmug][77]}" if @@debug
  end

  def log_out
    visit destroy_smugmug_session_url
  end

  #Sessions controller
  test "Log in, test connector functionality, then log out" do
    log_in
    assert_contain "Signed in"

    # "Get photoset list (HTML)" do
    visit smugmug_folders_url
    assert_contain "Halloween 2008"
    assert_contain "Fabulous me!"

    # "Get photoset list (JSON)" do
    visit smugmug_folders_url(:format => 'json')
    result = JSON.parse response.body
    assert result[0]['name'] == 'Halloween 2008'
    assert result[1]['name'] == 'Fabulous me!'

    # "Import whole photoset (JSON)" do
    visit smugmug_folder_action_url(:sm_album_id => '6467864_mKdzn', :action => :import, :format => :json, :album_id => 1)
    result = JSON.parse response.body
    assert result.size == 38
    result.each do |r|
      assert r['caption'] =~ /\d{4}-\d{2}-\d{2}-Serra Halloween-\d{4}\.jpg/
    end

    #Photos controller
    # "Get photos list from 1st photoset" do
    visit smugmug_photos_url(:sm_album_id => '6467864_mKdzn', :format => :json)
    result = JSON.parse response.body
    assert result.size == 38
    result.each do |r|
      assert r['name'] =~ /\d{4}-\d{2}-\d{2}-Serra Halloween-\d{4}\.jpg/
    end

    # "Get photos list from 2nd photoset" do
    visit smugmug_photos_url(:sm_album_id => '5298215_9VoYf', :format => :json)
    result = JSON.parse response.body
    assert result.size == 1
    assert result[0]['name'] == 'running'

    # "Get photo thumbnail from 1st photoset" do
    visit smugmug_photo_url(:sm_album_id => '6467864_mKdzn', :photo_id => '412839635_dFxkP', :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/

    # "Get photo thumbnail from 2nd photoset" do
    visit smugmug_photo_url(:sm_album_id => '5298215_9VoYf', :photo_id => '323165888_x2jWq', :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/

    # "Import photo from a photoset (JSON)" do
    visit smugmug_photo_action_url(:sm_album_id => '6467864_mKdzn', :photo_id => '412839635_dFxkP', :action => :import, :format => :json, :album_id => 1)
    result = JSON.parse response.body
    assert result['caption'] =~ /\d{4}-\d{2}-\d{2}-Serra Halloween-\d{4}\.jpg/

    log_out
    assert_contain "Signed out"
  end

end