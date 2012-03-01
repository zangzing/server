require 'spec_helper'

describe PhotosController do

  describe "#index" do
    it "should redirect to owner's homepage if album is missing" do
      album_owner = Factory(:user)
      bad_album_id = 123344
      get :index, {:album_id=>bad_album_id, :user_id=>album_owner.username}
      response.status.should be(302)
      response.header['Location'].should == user_url(album_owner)
    end
  end

  describe "#show" do
    it "should redirect to owner's homepage if album is missing" do
      album_owner = Factory(:user)
      bad_album_id = 123344
      fake_photo_id = 12334
      get :show, {:album_id=>bad_album_id, :photo_id=>fake_photo_id, :user_id=>album_owner.username}
      response.status.should be(302)
      response.header['Location'].should == user_url(album_owner)
    end
  end
end

describe AlbumsController do

  describe "#index" do
    include PrettyUrlHelper
    include ControllerSpecHelper
    
    it "should redirect to current user's homepage if user is missing" do
      login

      get :index, {:user_id=>"bad_user_name"}
      response.status.should be(302) #google doesn't see this one
      response.header['Location'].should == user_url(@current_user)
    end

    it "should redirect to POTD if user is missing and no current user" do
      get :index, {:user_id=>"bad_user_name"}
      response.status.should be(302)
      response.header['Location'].should include potd_path
    end
  end
end


describe ActivitiesController do
  describe "#user_index" do
    include PrettyUrlHelper
    include ControllerSpecHelper

    it "should redirect to current user's homepage if user is missing" do
      login
      get :user_index, {:user_id=>"bad_user_name"}
      response.status.should be(302) #google doesn't see this one
      response.header['Location'].should == user_url(@current_user)
    end

    it "should redirect to POTD if user is missing and no current user" do
      get :user_index, {:user_id=>"bad_user_name"}
      response.status.should be(302)
      response.header['Location'].should include potd_path
    end
  end


  describe "#album_index" do
    it "should redirect to owner's homepage if album is missing" do
      album_owner = Factory(:user)
      bad_album_id = 123344
      get :album_index, {:album_id=>bad_album_id, :user_id=>album_owner.username}
      response.status.should be(302)
      response.header['Location'].should == user_url(album_owner)
    end
  end

  end


describe PeopleController do
  describe "#user_index" do
    include PrettyUrlHelper
    include ControllerSpecHelper

    it "should redirect to current user's homepage if user is missing" do
      login
      get :user_index, {:user_id=>"bad_user_name"}
      response.status.should be(302) #google doesn't see this one
      response.header['Location'].should == user_url(@current_user)
    end

    it "should redirect to POTD if user is missing and no current user" do
      get :user_index, {:user_id=>"bad_user_name"}
      response.status.should be(302)
      response.header['Location'].should include potd_path
    end
  end


  describe "#album_index" do
    it "should redirect to owner's homepage if album is missing" do
      album_owner = Factory(:user)
      bad_album_id = 123344
      get :album_index, {:album_id=>bad_album_id, :user_id=>album_owner.username}
      response.status.should be(302)
      response.header['Location'].should == user_url(album_owner)
    end
  end

end
