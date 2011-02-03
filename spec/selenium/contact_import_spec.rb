require 'spec/selenium/ui_model'
require 'spec/selenium/uimodel_helper'
require 'spec/selenium/connector_shared'

describe "contributors test" do
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
  
  it "import mslive contacts" do
    ui.wizard.album_contributors_tab.import_gmail_contacts
  end
  
  it "verify contacts are imported" do
    ui.wizard.album_contributors_tab.imported_yahoo?.should be_false
    ui.wizard.album_contributors_tab.imported_gmail?.should be_true
  end
  
  

end
