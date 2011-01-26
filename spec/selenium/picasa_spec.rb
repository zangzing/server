require 'spec/selenium/ui_model'
require 'spec/selenium/uimodel_helper'

describe "Picasa Web connector" do
  include UimodelHelper

  before(:all) do
    @browser_session = UiModel::SeleniumSession.new
    @browser_session.create_session!

    ui.open_site!
  end

  after(:all) do
    @browser_session.close_session!
  end

  it "joins as new user" do
    ui.toolbar.open_sign_in_drawer

    ui.toolbar.signin_drawer.click_join_tab
    
    ui.toolbar.signin_drawer.join_tab.visible?.should be_true

    ui.toolbar.signin_drawer.join_tab.type_full_user_name current_user[:full_name]
    ui.toolbar.signin_drawer.join_tab.type_username current_user[:username]
    ui.toolbar.signin_drawer.join_tab.type_email current_user[:email]
    ui.toolbar.signin_drawer.join_tab.type_password current_user[:password]
  	ui.toolbar.signin_drawer.join_tab.click_join_button

    ui.toolbar.signed_in_as?(current_user[:username]).should be_true
  end

  it "creates a new group album" do
    ui.toolbar.click_create_album

    ui.wizard.album_type_tab.visible?.should be_true

    ui.wizard.album_type_tab.click_group_album

    ui.wizard.add_photos_tab.visible?.should be_true
  end

  it "connects to Picasa Web, opens My Albums" do
    ui.wizard.add_photos_tab.at_home?.should be_true

    ui.wizard.add_photos_tab.click_folder "Picasa Web"
    ui.oauth_manager.login_to_picasa

  end

  it "adds one random photo from Picasa's 'MediumAlbum'" do
    ui.wizard.add_photos_tab.click_folder "MediumAlbum"
    ui.wizard.add_photos_tab.add_random_photos(1)

    ui.wizard.add_photos_tab.back_level_up
  end
  
  it "adds the whole 'Small Album' with 20 photos" do
    ui.wizard.add_photos_tab.at_home?.should_not be_true
    ui.wizard.add_photos_tab.add_all_folder "SmallAlbum"
  end

  it "gives a name to the album" do
    ui.wizard.click_name_tab

    ui.wizard.album_name_tab.visible?.should be_true

    @@album_name = "Picasa #{current_user[:stamp]}"
    ui.wizard.album_name_tab.type_album_name @@album_name
  end

  it "closes wizard" do
    ui.wizard.click_share_tab
    ui.wizard.click_done
    ui.wait_load
  end

  it "checks if newly created album contains 21 photos" do
    ui.toolbar.click_zz_logo
    ui.wait_load
    ui.user_homepage.inside_album_list?.should be_true
    
    albums = ui.user_homepage.get_album_list
    albums.include?(@@album_name).should be_true
    
    ui.user_homepage.click_album @@album_name
    ui.user_homepage.inside_album?.should be_true

    photos = ui.user_homepage.get_photos_list
    photos.should == 21
  end

end
