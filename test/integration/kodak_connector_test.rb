require 'test_helper'

class KodakConnectorTest < ActionController::IntegrationTest
  #fixtures :all
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
  
  #Sessions controller
  test "Log in using correct credentials and log out" do
    log_in(true)
    assert_contain "Signed in"
    log_out
    assert_contain "Signed out"
  end

  test "Log in using invalid credentials" do
    log_in(false)
    assert status==401
  end
  
  #Folders controller
  test "Get album list (HTML)" do
    log_in
    visit kodak_folders_url
    assert_contain "Test-Album-01"
    assert_contain "Test-Album-02"
  end

  test "Get album list (JSON)" do
    log_in
    visit kodak_folders_url(:format => 'json')
    result = JSON.parse response.body
    result.each do |r|
      assert r['name'] =~ /Test-Album-0\d/
    end
  end

  test "Import whole folder (JSON)" do
    log_in
    visit kodak_folder_action_url(:kodak_album_id => 118686908115, :action => :import, :format => :json)
    result = JSON.parse response.body
    result.each do |r|
      assert r['image_file_name'] =~ /DSC_\d{4}.*/
    end
  end
  
  #Photos controller
  test "Get photos list from 1st album" do
    log_in
    visit kodak_photos_url(:kodak_album_id => 118686908115)
    assert_contain "DSC_0185"
    assert_contain "DSC_0188"
    assert_contain "DSC_0189"
  end

  test "Get photos list from 2nd album" do
    log_in
    visit kodak_photos_url(:kodak_album_id => 513508908115)
    assert_contain "DSC_0316"
    assert_contain "DSC_0322"
    assert_contain "DSC_0313"
    assert_contain "DSC_0313"
  end
  
  test "Get photo thumbnail from 1st album" do
    log_in
    visit kodak_photo_url(:kodak_album_id => 118686908115, :photo_id => 754857908115, :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/
  end

  test "Get photo thumbnail from 2nd album" do
    log_in
    visit kodak_photo_url(:kodak_album_id => 513508908115, :photo_id => 818658908115, :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/
  end

  test "Import photo from an album (JSON)" do
    log_in
    visit kodak_photo_action_url(:kodak_album_id => 513508908115, :photo_id => 939618908115, :action => :import, :format => :json)
    result = JSON.parse response.body
    assert result['image_file_name'] =~ /DSC_\d{4}.*/
  end



end
