require 'spec/selenium/ui_model'
require 'spec/selenium/uimodel_helper'
require 'spec/selenium/connector_shared'

describe "My pictures connector" do
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

  it "connects to My Pictures" do
    ui.wizard.add_photos_tab.click_folder "My pictures"
  end

  it "adds 5 random photos from 'My pictures" do
    import_random_photos(5)
  end

  it "gives a name to the album" do
    @@album_name = "My pictures #{current_user[:stamp]}"
    set_album_name @@album_name
  end

  it "closes wizard" do
    close_wizard
  end

  it "checks if newly created album contains 5 photos" do
    photos = get_photos_from_added_album(@@album_name)
    photos.count.should == 5
  end

end
