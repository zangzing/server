require 'spec_helper'

describe CommentsController do
  include ControllerSpecHelper
  

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    FacebookPublisher.test_mode = true
    FacebookPublisher.test_posts = []

    TwitterPublisher.test_mode = true
    TwitterPublisher.test_posts = []

    login
  end


  describe '#delete action' do
    it "should fail if no current user" do
      logout
      xhr :delete, :destroy, {:comment_id => 1}
      response.status.should be(401)
    end


    it "should allow comment owner to delete comment" do
      comment = Factory.create(:photo_comment)
      comment.user = @current_user
      comment.save!

      xhr :delete, :destroy, {:comment_id => comment.id}
      response.status.should be(200)
    end


    it "should allow photo owner to delete comment" do
      comment = Factory.create(:photo_comment)
      photo = comment.commentable.subject
      photo.user = @current_user
      photo.save!

      xhr :delete, :destroy, {:comment_id => comment.id}
      response.status.should be(200)
    end

    it "should allow album owner to delete comment" do
      comment = Factory.create(:photo_comment)
      photo = comment.commentable.subject
      album = photo.album
      album.user = @current_user
      album.save!

      xhr :delete, :destroy, {:comment_id => comment.id}
      response.status.should be(200)
    end

    it "should not allow anyone else to delete comment" do
      comment = Factory.create(:photo_comment)

      xhr :delete, :destroy, {:comment_id => comment.id}
      response.status.should be(401)
    end


  end

  describe "#index action" do
#    it "should fail if no current user" do
#      logout
#
#      photo = Factory.create(:photo)
#
#      xhr :get, :index, {:photo_id => photo.id}
#      response.status.should be(401)
#    end

    it "should fail if user does not have permission to view album" do
      photo = Factory.create(:photo)
      album = photo.album
      album.privacy = Album::PASSWORD
      album.save!

      xhr :get, :index , {:photo_id => photo.id}
      response.status.should be(401)
    end

    it "should return comment json for valid photo" do
      photo = Factory.create(:photo)


      xhr :get, :index , {:photo_id => photo.id}
      response.should be_success
    end
  end

  describe "#metadata_for_album_photos action" do
#    it "should fail if no current user" do
#      album = Factory.create(:album)
#      logout
#      xhr :get, :metadata_for_album_photos, {:album_id => album.id}
#      response.status.should be(401)
#    end

    it "should fail if user does not have permission to view album" do
      album = Factory.create(:album)
      album.privacy = Album::PASSWORD
      album.save!

      xhr :get, :metadata_for_album_photos , {:album_id => album.id}
      response.status.should == 401
    end


  end

  describe "#metadata_for_subjects action" do
#    it "should fail if no current user" do
#      logout
#      xhr :get, :metadata_for_subjects, {:subjects=>[]}
#      response.status.should be(401)
#    end


    it 'should return metadata for all photos in album' do
      album = Factory.create(:album)

      photo1 = Factory.create(:photo, :album => album)
      Factory.create(:comment, :commentable => Commentable.find_or_create_by_photo_id(photo1.id))

      photo2 = Factory.create(:photo, :album => album)
      Factory.create(:comment, :commentable => Commentable.find_or_create_by_photo_id(photo2.id))


      params = {
        :subjects => [
          {
            :id => photo1.id,
            :type => 'photo'
          },
          {
            :id => photo2.id,
            :type => 'photo'
          }
        ]
      }

      xhr :get, :metadata_for_subjects, params
      response.status.should be(200)

      body = JSON.parse(response.body)
      body.length.should eql(2)
      body[0]['subject_type'].should eql('photo')
      body[1]['subject_type'].should eql('photo')
    end
  end



  describe "#create action" do
    it 'should create new comment for photo' do
      photo = Factory(:photo)

      xhr :post, :create, {:photo_id=>photo.id, :comment=>{:text=>"This is a comment"}}
      response.status.should be(200)

      commentable = Commentable.find_by_photo_id(photo.id)
      commentable.comments.length.should eql(1)
    end

    it "should fail if user does not have permission to view album" do
      photo = Factory(:photo)
      album = Factory(:album)
      photo.album = album
      album.privacy = Album::PASSWORD
      photo.save!
      album.save!

      xhr :post, :create, {:photo_id=>photo.id, :comment=>{:text=>"This is a comment"}}
      response.status.should be(401)
    end

  end
end