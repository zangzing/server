require 'test_helper'

class KodakConnectorTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup
    ensure_logged_in
  end

  KODAK_CREDENTIALS = {:email => 'dev@zangzing.com', :password => 'ijertyewij'}

  test "Routing" do
    #Sessions
    assert_routing "/kodak/sessions/new", {:controller => "kodak_sessions", :action => "new"}
    assert_routing "/kodak/sessions/create", {:controller => "kodak_sessions", :action => "create"}
    assert_routing "/kodak/sessions/destroy", {:controller => "kodak_sessions", :action => "destroy"}
    #Folders
    assert_routing "/kodak/folders", {:controller => "kodak_folders", :action => "index"}
    assert_routing "/kodak/folders/456/import", {:controller => "kodak_folders", :action => "import", :kodak_album_id => '456'}
    #Photos
    assert_routing "/kodak/folders/123/photos", {:controller => "kodak_photos", :action => "index", :kodak_album_id => "123"}
    assert_routing "/kodak/folders/123/photos/456.screen", {:controller => "kodak_photos", :action => "show", :kodak_album_id => "123", :photo_id => "456", :size => 'screen'}
    assert_routing "/kodak/folders/123/photos/456/import", {:controller => "kodak_photos", :action => "import", :kodak_album_id => "123", :photo_id => "456"}
  end

  def log_in(valid_credentials = true)
    visit new_kodak_session_url
    fill_in "email", :with => valid_credentials ? KODAK_CREDENTIALS[:email] : 'foo'
    fill_in "password", :with => valid_credentials ? KODAK_CREDENTIALS[:password] : 'bar'
    click_button 'Log in'
  end

  def log_out
    visit destroy_kodak_session_url
  end
  
  test "Log in using correct credentials, test connector, log out" do
    log_in(true)
    assert_contain "Signed in"
    
    #"Get album list (HTML)"
    visit kodak_folders_url
    assert_contain "Test-Album-01"
    assert_contain "Test-Album-02"
    
    #"Get album list (JSON)"
    visit kodak_folders_url(:format => 'json')
    result = JSON.parse response.body
    #puts "RESPONSE >>> Get album list (JSON) >>>> #{result.inspect}"
    result.each do |r|
      assert r['name'] =~ /Test-Album-0\d/
    end
    
    #"Import whole folder (JSON)"
    visit kodak_folder_action_url(:kodak_album_id => 118686908115, :action => :import, :format => :json, :album_id => 1)
    result = JSON.parse response.body
    #puts "RESPONSE >>> Import whole folder (JSON) >>>> #{result.inspect}"
    result.each do |r|
      assert r['caption'] =~ /DSC_\d{4}.*/
    end
    
    #"Get photos list from 1st album"
    visit kodak_photos_url(:kodak_album_id => 118686908115)
    assert_contain "DSC_0185"
    assert_contain "DSC_0188"
    assert_contain "DSC_0189"    
    
    #"Get photos list from 2nd album"
    visit kodak_photos_url(:kodak_album_id => 513508908115)
    assert_contain "DSC_0316"
    assert_contain "DSC_0322"
    assert_contain "DSC_0313"
    assert_contain "DSC_0313"
    
    #"Get photo thumbnail from 1st album"
    visit kodak_photo_url(:kodak_album_id => 118686908115, :photo_id => 754857908115, :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/
    
    #"Get photo thumbnail from 2nd album"
    visit kodak_photo_url(:kodak_album_id => 513508908115, :photo_id => 818658908115, :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/
    
    #"Import photo from an album (JSON)"
    visit kodak_photo_action_url(:kodak_album_id => 513508908115, :photo_id => 939618908115, :action => :import, :format => :json, :album_id => 1)
    result = JSON.parse response.body
    assert result['caption'] =~ /DSC_\d{4}.*/
    
    log_out
    assert_contain "Signed out"
  end

  test "Log in using invalid credentials" do
    log_in(false)
    assert status==401
  end
  
end
