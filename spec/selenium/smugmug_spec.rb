require './spec/selenium/ui_model'
require './spec/selenium/uimodel_helper'
require './spec/selenium/connector_shared'

describe "SmugMug connector" do
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

  it "connects to SmugMug" do
    connect_to_service(:smugmug, 'SmugMug')
  end

  it "adds the whole 'Small Album' with 20 photos" do
    ui.wizard.add_photos_tab.click_folder "Photos-for-testing"
    click_import_all_photos
  end

  it "gives a name to the album" do
    @@album_name = "SmugMug #{current_user[:stamp]}"
    set_album_name @@album_name
  end

  it "closes wizard" do
    close_wizard
  end

  it "checks if newly created album contains 68 photos" do
    photos = get_photos_from_added_album(@@album_name)
    photos.count.should == 68
  end

end
