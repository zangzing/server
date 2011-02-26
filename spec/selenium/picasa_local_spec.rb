require 'spec/selenium/ui_model'
require 'spec/selenium/uimodel_helper'
require 'spec/selenium/connector_shared'

describe "Picasa local connector" do
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

  it "connects to Picasa local" do
    ui.wizard.add_photos_tab.click_folder "Picasa"
    @@no_agent = ui.wizard.add_photos_tab.agent_not_installed?
    throw 'ZangZing agent is not installed!' if @@no_agent
    ui.wizard.add_photos_tab.click_folder "Folders"
    ui.wizard.add_photos_tab.click_folder "Pictures"
  end

  it "adds 5 random photos from 'Picasa local" do
    unless @@no_agent
      import_random_photos(5)
    end
  end

  it "gives a name to the album" do
    unless @@no_agent
      @@album_name = "Picasa local #{current_user[:stamp]}"
      set_album_name @@album_name
    end
  end

  it "closes wizard" do
    unless @@no_agent
      close_wizard
    end
  end

  it "checks if newly created album contains 5 photos" do
    unless @@no_agent
      photos = get_photos_from_added_album(@@album_name)
      photos.count.should == 5
    end
  end

end
