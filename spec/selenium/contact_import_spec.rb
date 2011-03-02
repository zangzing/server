require 'spec/selenium/ui_model'
require 'spec/selenium/uimodel_helper'
require 'spec/selenium/connector_shared'

describe "Contact import test" do
  include UimodelHelper

  include ConnectorShared

  before(:all) { begin_session! }
  after(:all) { end_session! }

  
  it "join as new user" do
	join_as_new_user
  end

  it "create a new group album" do
    create_new_album(:group)
  end

  it "go to contributors tab" do
    ui.wizard.click_contributors_tab
  end
  
  it "import gmail contacts" do
    ui.wizard.album_contributors_tab.import_gmail_contacts
  end
  
  it "import yahoo contacts" do
    ui.wizard.album_contributors_tab.import_yahoo_contacts
  end
  
  it "import mslive contacts" do
    ui.wizard.album_contributors_tab.import_mslive_contacts
  end

  it "import outlook contacts" do
    ui.wizard.album_contributors_tab.import_outlook_contacts
    if ui.wizard.add_photos_tab.agent_not_installed?
      @@no_agent = true 
      ui.browser.key_down('css=#no-agent-dialog', '\27')
      ui.browser.key_up('css=#no-agent-dialog', '\27')
      throw "ZangZing Agent not installed!"
    end
  end
  
  it "verify contacts from yahoo are imported" do
    ui.wizard.album_contributors_tab.imported_yahoo?.should be_true
  end


  it "verify contacts from gmail are imported" do
    ui.wizard.album_contributors_tab.imported_gmail?.should be_true
  end
  
  it "verify contacts from mslive are imported" do
    ui.wizard.album_contributors_tab.imported_mslive?.should be_true
  end    

  it "verify contacts from outlook are imported" do
    ui.wizard.album_contributors_tab.imported_outlook?.should be_true unless @@no_agent
  end

end
