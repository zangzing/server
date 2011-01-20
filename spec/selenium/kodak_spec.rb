require 'spec/selenium/ui_model'

describe "Facebook connector" do

  def ui
    @browser_session
  end

  before(:all) do
    @browser_session = UiModel::SeleniumSession.new
    @browser_session.create_session!
  end

  after(:all) do
    @browser_session.close_session!
  end

  it "should create album with one photo from Kodak's 'Medium Album' and all 3 photos from 'Small Album'" do
    username = 'user' +Time.now.to_i.to_s
    password = 'share1001photos'
    email = username + "@test.zangzing.com"

    ui.open_site!

    ui.toolbar.open_sign_in_drawer
	
    ui.toolbar.click_join_tab

    ui.signin_drawer_join_tab.type_full_user_name username
    ui.signin_drawer_join_tab.type_username username
    ui.signin_drawer_join_tab.type_email email
    ui.signin_drawer_join_tab.type_password password
  	ui.signin_drawer_join_tab.click_join_button
	
    ui.toolbar.verify_signed_in_user username

    ui.toolbar.click_create_album
    ui.wizard_album_type_tab.click_group_album
   
    ui.wizard_add_photos_tab.click_folder "Kodak"
    ui.oauth_manager.login_to_kodak

    ui.wizard_add_photos_tab.click_folder "Medium Album"
    
    ui.wizard_add_photos_tab.add_random_photos

    ui.wizard_drawer.back_level_up

    #add the whole 'Small Album'
    ui.wizard_add_photos_tab.add_all_folder "Small Album"
    #close the wizard
    ui.wizard_drawer.click_done

    ui.wait_load
    
    ui.toolbar.click_zz_logo
    
  end
end
