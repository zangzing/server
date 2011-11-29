#
# This spec tests the response actions controller methods see response_action_helper
#
require 'spec_helper'
include ResponseActionsHelper


describe 'ResponseActionsHelper' do

  describe 'add_javascript_action' do
    it 'should add a jsactions array into the session' do
      #Add first js response action
      session[:jsactions].should be nil
      helper.add_javascript_action( 'show_message_dialog', {:message => 'This is a message to you, you, you'})
      session[:jsactions].should_not be nil
      session[:jsactions].length.should == 1
      session[:jsactions][0][:method].should == 'show_message_dialog'
      session[:jsactions][0][:message].should == 'This is a message to you, you, you'

      #Add second js response action
      helper.add_javascript_action( 'send_zza_event_from_client', {:event => 'spec.test'})
      session[:jsactions].length.should == 2
      session[:jsactions][1][:method].should == 'send_zza_event_from_client'
      session[:jsactions][1][:event].should == 'spec.test'
    end
  end

  describe 'add_render_action' do
    it 'should add a ractions entry into the session' do
      #Add first js response action
      session[:ractions].should be nil
      helper.add_render_action( 'show_request_access_dialog', {:album_id => '25'})
      session[:ractions].should_not be nil
      session[:ractions].length.should == 1
      session[:ractions][0][:method].should == 'show_request_access_dialog'
      session[:ractions][0][:album_id].should == '25'

      #Add second js response action
      helper.add_render_action( 'show_request_contributor_dialog', {:album_id => '32'})
      session[:ractions].length.should == 2
      session[:ractions][1][:method].should == 'show_request_contributor_dialog'
      session[:ractions][1][:album_id].should == '32'
    end
  end

  describe 'perform_response_actions' do
    it 'it should throw an exception if the response action method name is unknown' do
      helper.add_javascript_action( 'bogus_client_js_action')
      lambda{ perform_javascript_actions }.should raise_error
    end
  end


  describe 'js_show_welcome_dialog( action )' do
    it 'should produce show_welcome_dialog js directive' do
      helper.add_javascript_action( 'show_welcome_dialog')
      perform_javascript_actions.should  contain("zz.welcome.show_welcome_dialog();")
    end
  end

  describe 'js_show_message_dialog( action )' do
    it 'should require message argument' do
      helper.add_javascript_action( 'show_message_dialog').should raise_error( Exception, /^.*message.*$/)
    end

    it 'should produce show_flash_dialog js directive' do``
      helper.add_javascript_action( 'show_message_dialog', {:message => "This is the message"})
      perform_javascript_actions.should contain( "zz.dialog.show_flash_dialog('This is the message'")
    end
  end

  describe 'js_show_add_photos_dialog( action )' do
    it 'should produce zz.photochooser.open_in_dialog directive' do
      helper.add_javascript_action( 'show_add_photos_dialog')
      result = perform_javascript_actions
      result.should contain( "zz.photochooser.open_in_dialog(zz.page.album_id, function() {" )
      result.should contain( "window.location.reload(false);" )
    end
  end


  describe 'js_send_zza_event_from_client( action )' do
    it 'should require event argument' do
      lambda{ helper.js_send_zza_event_from_client( {} ) }.should raise_error(Exception, /^.*event$/)
    end

    it 'should produce one or more ZZAt.track js directives' do
       helper.add_javascript_action("send_zza_event_from_client", {:event => "test.event1.click"})
       helper.add_javascript_action("send_zza_event_from_client", {:event => "test.event2.click"})
       result = perform_javascript_actions
       result.should contain( "ZZAt.track('#{ escape_javascript  "test.event1.click"}');" )
       result.should contain( "ZZAt.track('#{ escape_javascript  "test.event2.click"}');" )
    end
  end

  describe 'js_show_album_wizard( action )' do
    it 'should require step argument' do
      lambda{ helper.js_show_album_wizard( {} )}.should raise_error( Exception, /^.*a wizard step$/)
    end

    it 'group should produce zz.wizard.open_group_tab directive' do
      helper.add_javascript_action( 'show_album_wizard', {:step => 'group', :email=>'def@leppard.com'})
      perform_javascript_actions.should contain( "zz.wizard.open_group_tab")
      helper.add_javascript_action( 'show_album_wizard', {:step => 'group'})
      perform_javascript_actions.should contain( "zz.wizard.open_group_tab")
    end
  end

  describe  'render_show_request_access_dialog( action )' do
    it 'should require album_id argument' do
      lambda{ helper.render_show_request_access_dialog({})}.should raise_error( Exception , /^.*album_id$/)
    end

    it 'should render albums/pwd_dialog' do
      helper.add_render_action("show_request_access_dialog",{ :album_id => '23' })
      perform_render_actions.should have_selector("textarea#request_access_message")
    end

  end

  describe 'render_show_request_contributor_dialog( action )' do
    it 'should require album_id argument' do
      lambda{helper.render_show_request_contributor_dialog({})}.should raise_error( Exception , /^.*album_id$/)
    end
    it 'should render albums/contributor_dialog' do
      helper.add_render_action("show_request_contributor_dialog",{ :album_id => '23' })
      perform_render_actions.should contain('zz.routes.albums.request_contributor')
    end

  end
end