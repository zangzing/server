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

  describe '#delete action' do
    it "should fail if no current user" do
      logout
      xhr :delete, :destroy, {:comment_id => 1}
      response.status.should be(401)
    end

    def setup_album_photo_and_comment
      album = Factory(:album)
      album.user = Factory(:user)

      photo = Factory(:photo)
      photo.album = album
      photo.user = Factory(:user)

      commentable = Commentable.new
      commentable.subject_type = 'photo'
      commentable.subject_id = photo.id

      comment = Comment.new
      comment.commentable = commentable
      comment.user = Factory(:user)

      Photo.stub!(:find).and_return(photo)
      Comment.stub!(:find).and_return(comment)

      return album, photo, comment

    end

    it "should allow comment owner to delete comment" do
      album, photo, comment = setup_album_photo_and_comment
      comment.user = @current_user
      xhr :delete, :destroy, {:comment_id => 1}
      response.status.should be(200)
    end


    it "should allow photo owner to delete comment" do
      album, photo, comment = setup_album_photo_and_comment
      photo.user = @current_user
      xhr :delete, :destroy, {:comment_id => 1}
      response.status.should be(200)
    end

    it "should allow album owner to delete comment" do
      album, photo, comment = setup_album_photo_and_comment
      album.user = @current_user
      xhr :delete, :destroy, {:comment_id => 1}
      response.status.should be(200)
    end

    it "should not allow anyone else to delete comment" do
      album, photo, comment = setup_album_photo_and_comment
      xhr :delete, :destroy, {:comment_id => 1}
      response.status.should be(401)
    end


  end

  describe "#index action" do
    it "should fail if no current user" do
      logout
      xhr :get, :index, {:photo_id => 1}
      response.status.should be(401)
    end

    it "should fail if user does not have permission to view album" do
      photo = Factory(:photo)
      album = Factory(:album)
      photo.album = album
      album.privacy = Album::PASSWORD

      Photo.stub!(:find).and_return(photo)

      xhr :get, :index , {:photo_id => photo.id}
      response.status.should be(401)
    end

    it "should return comment json for valid photo" do
      xhr :get, :index , {:photo_id => 1}
      response.should be_success
    end
  end

  describe "#album_photos_metadata action" do
    it "should fail if no current user" do
      logout
      xhr :get, :album_photos_metadata, {:album_id => 1}
      response.status.should be(401)
    end

    it "should fail if user does not have permission to view album" do
      album = Factory(:album)
      album.privacy = Album::PASSWORD
      Album.stub!(:find).and_return(album)

      xhr :get, :album_photos_metadata , {:album_id => album.id}
      response.status.should be(401)
    end
  end
end