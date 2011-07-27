require 'spec_helper'

describe CommentsController do

  before(:each) do
    Photo.stub!(:find).and_return(Factory(:photo))
    login
  end

  def login
    @current_user = Factory(:user)
    controller.stub!(:current_user).and_return(@current_user)
  end

  def logout
    controller.stub!(:current_user).and_return(nil)
  end

  describe "index action" do
    it "should fail if no current user" do
      logout
      xhr :get, :index, {:photo_id => 1}
      response.status.should be(401)
    end

    it "should fail if user does not have permission to view album" do
      controller.stub!(:require_album_viewer_role).and_return(false)
      xhr :get, :index , {:photo_id => 1}
      response.status.should be(401)
    end

    it "should return comment json for valid photo" do
      xhr :get, :index , {:photo_id => 1}
      response.should be_success
    end
  end

  describe "metadata action" do
    it "should fail if no current user" do
      logout
      xhr :get, :metadata, {:photo_id => 1}
      response.status.should be(401)
    end

    it "should fail if user does not have permission to view album" do
      controller.stub!(:require_album_viewer_role).and_return(false)
      xhr :get, :metadata , {:photo_id => 1}
      response.status.should be(401)
    end
  end



end