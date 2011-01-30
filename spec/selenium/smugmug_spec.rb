require 'spec/selenium/ui_model'
require 'spec/selenium/uimodel_helper'
require 'spec/selenium/connector_shared'

describe "SmugMug connector" do
  include UimodelHelper

  include ConnectorShared

  before(:all) { begin_session! }
  after(:all) { end_session! }

  it "joins as new user" do
    join_as_new_user
  end

  it "creates a new group album" do
    create_new_album(:group)
  end

  it "connects to SmugMug" do
    connect_to_service(:smugmug, 'SmugMug')
  end

  it "adds one random photo from SmugMug's 'Medium Album'" do
    ui.wizard.add_photos_tab.click_folder "Medium Album"
    import_random_photos(1)
  end
  
  it "adds the whole 'Small Album' with 20 photos" do
    import_folder "Small Album"
  end

  it "gives a name to the album" do
    @@album_name = "SmugMug #{current_user[:stamp]}"
    set_album_name @@album_name
  end

  it "closes wizard" do
    close_wizard
  end

  it "checks if newly created album contains 21 photos" do
    photos = get_photos_from_added_album(@@album_name)
    photos.count.should == 21
  end

end
