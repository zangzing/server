require './spec/selenium/ui_model'
require './spec/selenium/uimodel_helper'
require './spec/selenium/connector_shared'

describe "My pictures connector" do
  include UimodelHelper
  include ConnectorShared

  before(:all) { begin_session! }
  after(:all) { end_session! }

  it "joins as new user" do
    join_as_new_user
  end

  it "creates a new group album" do
    create_new_album #(:group)
  end

  it "opens My Pictures" do
    ui.wizard.add_photos_tab.click_folder "My-Computer"
    ui.wizard.add_photos_tab.click_folder "My-Pictures"
    @@no_agent = ui.wizard.add_photos_tab.agent_not_installed?
    throw 'ZangZing agent is not installed!' if @@no_agent
  end

  it "adds 5 random photos from My Pictures' 'miniMediumAlbum'" do
    unless @@no_agent
      ui.wizard.add_photos_tab.click_folder "miniMediumAlbum"
      import_random_photos(5)
    end
  end

  it "adds 5 random photos from My Pictures' 'miniLargeAlbum'" do
    unless @@no_agent
      ui.wizard.add_photos_tab.click_folder "miniLargeAlbum"
      import_random_photos(5)
    end
  end

  it "adds the whole 'miniSmallAlbum' with 20 photos" do
    unless @@no_agent
      ui.wizard.add_photos_tab.click_folder "miniSmallAlbum"
      click_import_all_photos
    end
  end

  it "gives a name to the album" do
    unless @@no_agent
      @@album_name = "MyPictures #{current_user[:stamp]}"
      set_album_name @@album_name
    end
  end

  it "closes wizard" do
    close_wizard
  end

  it "checks if newly created album contains 15 photos" do
    unless @@no_agent
      photos = get_photos_from_added_album(@@album_name)
      photos.count.should == 15
    end
  end

end
