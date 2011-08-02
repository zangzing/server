require 'spec_helper'
require 'factory_girl'

describe "Comments Model" do

  describe Comment do

    it "should notify album owner, photo owner, and other commentors of new comments" do
      # setup
      photo = Factory.create(:photo, :album => Factory.create(:album), :user => Factory.create(:user))
      commentable = Commentable.find_or_create_by_photo_id(photo.id)
      existing_comment = Factory.create(:comment, :commentable => commentable, :user => Factory.create(:user))


      # add comment to photo
      comment = Factory.create(:comment, :commentable => commentable, :user => Factory.create(:user))

      # expect email to album owner
      ZZ::Async::Email.should_receive(:enqueue).with(:comment_added_to_photo, comment.user.id, photo.album.user.id, comment.id)

      # expect email to photo owner
      ZZ::Async::Email.should_receive(:enqueue).with(:comment_added_to_photo, comment.user.id, photo.user.id, comment.id)

      # expect email to other commenters
      ZZ::Async::Email.should_receive(:enqueue).with(:comment_added_to_photo, comment.user.id, existing_comment.user.id, comment.id)

      # run the test
      comment.send_notification_emails
    end
  end


  describe Commentable do

    it "should cache comment count" do
      commentable = Commentable.find_or_create_by_photo_id(12345)
      Factory.create(:comment, :commentable => commentable)
      Factory.create(:comment, :commentable => commentable)

      commentable = Commentable.find(commentable.id)
      commentable.comments.length.should eql(2)
      commentable.comments_count.should eql(2)

    end

    it "should include user information in comment json" do
      commentable = Commentable.find_or_create_by_photo_id(12345)
      Factory.create(:comment, :commentable => commentable)
      Factory.create(:comment, :commentable => commentable)

      commentable = Commentable.find(commentable.id)
      commentable.comments.length.should eql(2)

      hash = commentable.comments_as_json

      hash['comments'][0]['user']['profile_photo_url'].should_not be_nil
      hash['comments'][0]['user']['first_name'].should_not be_nil
      hash['comments'][0]['user']['last_name'].should_not be_nil
    end

    it "should return comment metadata for all photos in album" do
      album = Factory.create(:album)
      3.times do
        Factory.create(:comment, :commentable=> Commentable.find_or_create_by_photo_id(Factory.create(:photo, :album => album).id))
      end

      commentables = Commentable.find_for_album_photos(album.id)

      commentables.length.should eql(3)
      commentables[0].comments_count.should eql(1)
      commentables[1].comments_count.should eql(1)
      commentables[2].comments_count.should eql(1)

    end


    it 'should return comment metadata and comment details for photo' do
      photo = Factory.create(:photo)

      commentable = Commentable.find_or_create_by_photo_id(photo.id)
      comment = Factory.create(:comment, :commentable => commentable)

      hash = Commentable.photo_comments_as_json(photo.id)
      hash['comments_count'].should eql(1)
      hash['comments'].length.should eql(1)
      hash['comments'][0]['text'].should eql(comment.text)
      


    end

    it 'should return emtpy metadata and no comments if photo has no comments' do
        hash = Commentable.photo_comments_as_json(Factory.create(:photo).id)
        hash.keys.length.should eql(0)
    end

    it 'should allow searching by array of subject hashes; eg: [{:subject_id=>1,:subject_type=>"photo"}]' do
      Commentable.find_or_create_by_photo_id(12345)
      Commentable.find_or_create_by_photo_id(123456)

      subjects = [
        {
          :id => 12345,
          :type => 'photo'
        },
        {
          :id => 123456,
          :type => 'photo'
        }
      ]

      commentables = Commentable.find_by_subjects(subjects)
      commentables.length.should eql(2)
    end
  end
end