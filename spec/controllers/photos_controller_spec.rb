require 'spec_helper'

describe PhotosController do
  include ControllerSpecHelper

  describe 'Request Access: When requesting a private album that I have NOT been invited to' do
    before(:each) do
      @privateAlbum = Factory.create(:album)
      @privateAlbum.privacy = Album::PASSWORD
      @privateAlbum.save!
      login
    end

    it 'should redirect to the album owners homepage' do
      get :index, {:user_id =>   @privateAlbum.user.id, :album_id => @privateAlbum.id}
      response.code.should == '302'
      response.should redirect_to user_path(  @privateAlbum.user )
    end

    it 'session must have :show_request_access_dialog set to album id' do
      get :index, {:user_id =>  @privateAlbum.user.id, :album_id => @privateAlbum.id}
      session[:show_request_access_dialog].should == @privateAlbum.id
    end
  end
end