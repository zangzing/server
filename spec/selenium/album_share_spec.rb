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

  it "go to share tab" do
    ui.wizard.click_share_tab
  end
  
  #it "click share by social" do
	#ui.wizard.album_share_tab.click_share_by_social
  #end
  
  #it "click facebook checkbox" do
	#ui.wizard.album_share_tab.click_facebook
  #end  
  
  #it "click twitter checkbox" do
	#ui.wizard.album_share_tab.click_twitter
  #end

  #it "send message" do
    #ui.wizard.album_share_tab.send_message
  #end
  
  it "click share by email" do
	ui.wizard.album_share_tab.click_share_by_email
  end
  
  it "Send email to igor@test.zangzing.com" do
	ui.wizard.album_share_tab.send_email("igor@test.zangzing.com")
  end

end
