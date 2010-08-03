require 'test_helper'
require 'mechanize'

class FlickrConnectorTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup
    ensure_logged_in
  end

  CREDENTIALS = {:login => 'zangzing_dev', :password => 'clev-vid-arch-ab-a'}

  test "Routing" do
    #Sessions
    assert_routing "/flickr/sessions/new", {:controller => "flickr_sessions", :action => "new"}
    assert_routing "/flickr/sessions/create", {:controller => "flickr_sessions", :action => "create"}
    assert_routing "/flickr/sessions/destroy", {:controller => "flickr_sessions", :action => "destroy"}
    #Folders
    assert_routing "/flickr/folders", {:controller => "flickr_folders", :action => "index"}
    assert_routing "/flickr/folders/456/import", {:controller => "flickr_folders", :action => "import", :set_id => '456'}
    #Photos
    assert_routing "/flickr/folders/123/photos", {:controller => "flickr_photos", :action => "index", :set_id => "123"}
    assert_routing "/flickr/folders/123/photos/456.screen", {:controller => "flickr_photos", :action => "show", :set_id => "123", :photo_id => "456", :size => 'screen'}
    assert_routing "/flickr/folders/123/photos/456/import", {:controller => "flickr_photos", :action => "import", :set_id => "123", :photo_id => "456"}
  end
  

  def log_in(valid_credentials = true)
    agent = Mechanize.new { |a| a.user_agent_alias = 'Windows Mozilla' }
    page = agent.get new_flickr_session_url
    form = page.forms.first
    form.login = valid_credentials ? CREDENTIALS[:login] : 'foo'
    form.passwd = valid_credentials ? CREDENTIALS[:password] : 'bar'
    page = form.submit
    agent.follow_meta_refresh = false
    agent.redirect_ok = false
    begin
    page = agent.get page.meta[0].href #1st hop with <meta refresh>
    page = agent.get page.header['location'] #2nd hop
    page = agent.get page.header['location'] #3rd hop
    agent = nil
    create_session_link = page.header['location']
    frob = URI.decode(create_session_link).match(/frob=([0-9a-zA-Z\-_]+)/).to_a.last
    rescue
      frob = 'blah'
    end
    #puts "FROB=#{frob}"
    visit create_flickr_session_url(:frob => frob)
  end

  def log_out
    visit destroy_flickr_session_url
  end

  #Sessions controller
  test "Log in using correct credentials and log out" do
    log_in(true)
    assert_contain "Signed in"
    log_out
    assert_contain "signed out"
  end

  test "Log in using invalid credentials" do
    log_in(false)
    assert status==401
  end

  #Folders controller
  test "Get photoset list (HTML)" do
    log_in
    visit flickr_folders_url
    assert_contain "Test-Set-01"
    assert_contain "Test-Set-02"
  end

  test "Get photoset list (JSON)" do
    log_in
    visit flickr_folders_url(:format => 'json')
    result = JSON.parse response.body
    result.each do |r|
      assert r['name'] =~ /Test-Set-0\d/
    end
  end

  test "Import whole photoset (JSON)" do
    log_in
    visit flickr_folder_action_url(:set_id => 72157624268707475, :action => :import, :format => :json)
    result = JSON.parse response.body
    result.each do |r|
      assert r['photo']['title'] =~ /DSC_\d{4}.*/
    end
  end

  #Photos controller
  test "Get photos list from 1st photoset" do
    log_in
    visit flickr_photos_url(:set_id => 72157624268707475)
    assert_contain "DSC_0161"
    assert_contain "DSC_0159"
    assert_contain "DSC_0147"
  end

  test "Get photos list from 2nd photoset" do
    log_in
    visit flickr_photos_url(:set_id => 72157624393511168)
    # Photos in set: DSC_0147 (ID#4749151477)     DSC_0148 (ID#4749146659) . <false> is not true.
    assert_contain "DSC_0147"
    assert_contain "DSC_0148"
  end

  test "Get photo thumbnail from 1st photoset" do
    log_in
    visit flickr_photo_url(:set_id => 72157624268707475, :photo_id => 4749804696, :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/
  end

  test "Get photo thumbnail from 2nd photoset" do
    log_in
    visit flickr_photo_url(:set_id => 72157624393511168, :photo_id => 4749151477, :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/
  end

  test "Import photo from a photoset (JSON)" do
    log_in
    visit flickr_photo_action_url(:set_id => 72157624393511168, :photo_id => 4749151477, :action => :import, :format => :json)
    result = JSON.parse response.body
    assert result['photo']['title'] =~ /DSC_\d{4}.*/
  end

end
