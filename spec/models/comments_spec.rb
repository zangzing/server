require 'spec_helper'
require 'factory_girl'

describe "Comments Model" do

  describe Commentable do

    it "should cache comment count" do
      commentable = Commentable.find_or_create_by_photo_id(12345)

      comment = commentable.comments.new
      comment.text = "this is a comment"
      comment.user = Factory(:user)
      comment.save

      comment = commentable.comments.new
      comment.text = "this is another comment"
      comment.user = Factory(:user)
      comment.save

      commentable = Commentable.find(commentable.id)
      commentable.comments.length.should eql(2)
      commentable.comments_count.should eql(2)

    end

    it "should include user information in comment json" do
      commentable = Commentable.find_or_create_by_photo_id(12345)

      comment = commentable.comments.new
      comment.text = "this is a comment"
      comment.user = Factory(:user)
      comment.save

      comment = commentable.comments.new
      comment.text = "this is another comment"
      comment.user = Factory(:user)
      comment.save

      commentable = Commentable.find(commentable.id)
      commentable.comments.length.should eql(2)

      hash = commentable.comments_as_json

      hash['comments'][0]['user']['profile_photo_url'].should_not be_nil
      hash['comments'][0]['user']['first_name'].should_not be_nil
      hash['comments'][0]['user']['last_name'].should_not be_nil
    end

    it "should return comment metadata for all photos in album" do
      album = Factory.create(:album_with_photos)
      album.photos.each do |photo|
        commentable = Commentable.find_or_create_by_photo_id(photo.id)
        comment = commentable.comments.new
        comment.user = Factory(:user)
        comment.save!
      end

      hash = Commentable.album_photos_metadata_as_json(album.id)
      hash[0]['comments_count'].should eql(1)

    end


    it 'should return comment metadata and comment details for photo' do
      photo = Factory.create(:photo)

      commentable = Commentable.find_or_create_by_photo_id(photo.id)
      comment = Comment.new
      comment.text = 'test'
      comment.user = Factory(:user)
      commentable.comments << comment
      comment.save!

      hash = Commentable.photo_comments_as_json(photo.id)
      hash['comments_count'].should eql(1)
      hash['comments'].length.should eql(1)
      hash['comments'][0]['text'].should eql('test')
      


    end

    it 'should return emtpy metadata and no comments if photo has no comments' do
        hash = Commentable.photo_comments_as_json(Factory.create(:photo).id)
        hash.keys.length.should eql(0)
    end

  end


end