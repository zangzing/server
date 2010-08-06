require 'test_helper'
require 'mechanize'

class ShutterflyConnectorTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup
    ensure_logged_in
  end


  CREDENTIALS = {:login => 'dev@zangzing.com', :password => 'share1001'}
  
  test "Routing" do
    #Sessions
    assert_routing "/shutterfly/sessions/new", {:controller => "shutterfly_sessions", :action => "new"}
    assert_routing "/shutterfly/sessions/create", {:controller => "shutterfly_sessions", :action => "create"}
    assert_routing "/shutterfly/sessions/destroy", {:controller => "shutterfly_sessions", :action => "destroy"}
    #Folders
    assert_routing "/shutterfly/folders", {:controller => "shutterfly_folders", :action => "index"}
    assert_routing "/shutterfly/folders/456/import", {:controller => "shutterfly_folders", :action => "import", :sf_album_id => '456'}
    #Photos
    assert_routing "/shutterfly/folders/123/photos", {:controller => "shutterfly_photos", :action => "index", :sf_album_id => "123"}
    assert_routing "/shutterfly/folders/123/photos/456.screen", {:controller => "shutterfly_photos", :action => "show", :sf_album_id => "123", :photo_id => "456", :size => 'screen'}
    assert_routing "/shutterfly/folders/123/photos/456/import", {:controller => "shutterfly_photos", :action => "import", :sf_album_id => "123", :photo_id => "456"}
  end

  @@debug = false
  @@n=0
  def dump_pg(page)
    if @@debug
      puts "#{@@n+=1}) #{page.uri}";
      File.open("E:/sf#{@@n}.htm", 'w') do |f|
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
    visit new_shutterfly_session_path
    service_auth_url = response.redirected_to
    puts "#{@@n+=1}) #{service_auth_url}" if @@debug
    agent = Mechanize.new { |a| a.user_agent_alias = 'Windows Mozilla' }
    page = agent.get service_auth_url; dump_pg(page)
    signin_url = page.links.select { |lnk| lnk.to_s.include?('Sign in') }.first.href
    page = agent.get signin_url; dump_pg(page)
    form = page.forms.first
    form.userName = CREDENTIALS[:login]
    form.password = CREDENTIALS[:password]
    agent.follow_meta_refresh = false
    agent.redirect_ok = false
    page = form.submit; dump_pg(page)
    page = agent.get page.header['location']; dump_pg(page)
    create_session_link = page.header['location']
    puts "o_O) #{create_session_link}" if @@debug
    visit create_session_link
    puts response.body if @@debug
  end

  def log_out
    visit destroy_shutterfly_session_url
  end

  #Sessions controller
  test "Log in, test connector functionality, then log out" do
    log_in
    assert_contain "Signed in"

    # "Get photoset list (HTML)" do
    visit shutterfly_folders_url
    assert_contain "Album_1"
    assert_contain "Album_2"

    # "Get photoset list (JSON)" do
    visit shutterfly_folders_url(:format => 'json')
    result = JSON.parse response.body
    assert result[0]['name'] == 'Album_2'
    assert result[1]['name'] == 'Album_1'

    # "Import whole photoset (JSON)" do
    visit shutterfly_folder_action_url(:sf_album_id => '67b0de21d1acc82084fd', :action => :import, :format => :json, :album_id => 1)
    result = JSON.parse response.body
    assert result.size == 3
    result.each do |r|
      assert r['image_file_name'] =~ /DSC_\d{4}.JPG/
    end

    #Photos controller
    # "Get photos list from both photosets" do
    ['67b0de21d1acc82084fd', '67b0de21d1821ffc8441'].each do |sf_album_id|
      visit shutterfly_photos_url(:sf_album_id => sf_album_id, :format => :json)
      result = JSON.parse response.body
      assert result.size == 3
      result.each do |r|
        assert r['name'] =~ /DSC_\d{4}.JPG/
      end
    end
    
    # "Get photo thumbnail from 1st photoset" do
    visit shutterfly_photo_url(:sf_album_id => '67b0de21d1acc82084fd', :photo_id => '47a0d937b3127ccefaf4c0c0904500000033100AZsm7dmzZtGYPbz4G', :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/

    # "Get photo thumbnail from 2nd photoset" do
    visit shutterfly_photo_url(:sf_album_id => '67b0de21d1821ffc8441', :photo_id => '47a0d937b3127ccefaf59bea71a600000033100AZsm7dmzZtGYPbz4G', :size => :thumb)
    assert response['Content-Type'] =~ /image\/.+/

    # "Import photo from a photoset (JSON)" do
    visit shutterfly_photo_action_url(:sf_album_id => '67b0de21d1821ffc8441', :photo_id => '47a0d937b3127ccefaf59bea71a600000033100AZsm7dmzZtGYPbz4G', :action => :import, :format => :json, :album_id => 1)
    result = JSON.parse response.body
    assert result['image_file_name'] == 'DSC_0212.JPG'

    log_out
    assert_contain "Signed out"
  end

end