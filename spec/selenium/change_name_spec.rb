require './spec/selenium/ui_model'
require './spec/selenium/uimodel_helper'
require './spec/selenium/connector_shared'

describe "Change name" do
  include UimodelHelper
  include ConnectorShared

  before(:all) { begin_session! }
  after(:all) { end_session! }

  it "joins as new user" do
    join_as_new_user
  end

  it "go to setting tab" do
    ui.toolbar.click_settings
  end

  it "change last and first name" do
    ui.settings_tab.type_first_name 'firstname'
    ui.settings_tab.type_last_name 'lastname'
    ui.settings_tab.click_done
  end

  it "verify name is changed" do
    ui.toolbar.signed_in_as? "firstname lastname"
  end


end