require 'spec_helper'
require 'factory_girl'

comments_resque_filter = { :except => [ZZ::Async::MailingListSync] }

describe "Comments Model" do

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    FacebookPublisher.test_mode = true
    FacebookPublisher.test_posts = []

    TwitterPublisher.test_mode = true
    TwitterPublisher.test_posts = []
  end


  describe Comment do
    it "should not notify likers who are not in the ablums ACL who liked the album before it was made private" do
      resque_jobs(comments_resque_filter) do
        # setup
        photo = Factory.create(:photo)

        # people like album and photo before album made private
        user_who_likes_photo  = Factory.create(:user)
        user_who_likes_photo.save!
        Like.add(user_who_likes_photo.id, photo.id, Like::PHOTO)

        user_who_likes_album  = Factory.create(:user)
        user_who_likes_album.save!
        Like.add(user_who_likes_album.id, photo.album.id, Like::ALBUM)

        # album made private
        album = photo.album
        album.make_private
        album.save!

        # comment created and notifications sent
        commentable = Commentable.find_or_create_by_photo_id(photo.id)
        comment = Factory.create(:comment, :commentable => commentable)
        comment.send_notification_emails


        # make sure the likers are not notified
        ActionMailer::Base.deliveries.should_not satisfy do |messages|
          messages.index { |message| message.to == [user_who_likes_photo.email] }
        end

        ActionMailer::Base.deliveries.should_not satisfy do |messages|
          messages.index { |message| message.to == [user_who_likes_album.email] }
        end
      end
    end

    it "should notify album likers and photo likers of new comments" do
      resque_jobs(comments_resque_filter) do
        # setup
        photo = Factory.create(:photo)

        commentable = Commentable.find_or_create_by_photo_id(photo.id)

        user_who_likes_photo  = Factory.create(:user)
        user_who_likes_photo.save!
        Like.add(user_who_likes_photo.id, photo.id, Like::PHOTO)

        user_who_likes_album  = Factory.create(:user)
        user_who_likes_album.save!
        Like.add(user_who_likes_album.id, photo.album.id, Like::ALBUM)



        # add comment to photo
        comment = Factory.create(:comment, :commentable => commentable)

        # run the test
        comment.send_notification_emails

        # expect email to user who likes photo
        ActionMailer::Base.deliveries.should satisfy do |messages|
          messages.index { |message| message.to == [user_who_likes_photo.email] }
        end

        # expect email to user who likes album
        ActionMailer::Base.deliveries.should satisfy do |messages|
          messages.index { |message| message.to == [user_who_likes_album.email] }
        end
      end
    end


    it "should notify album owner, photo owner, and other commentors of new comments" do
      resque_jobs(comments_resque_filter) do
        # setup
        album_owner = Factory.create(:user)
        album = Factory.create(:album, :user => album_owner)

        photo_owner = Factory.create(:user)
        photo = Factory.create(:photo, :user => photo_owner, :album => album)

        commentable = Commentable.find_or_create_by_photo_id(photo.id)
        existing_comment = Factory.create(:comment, :commentable => commentable, :user => Factory.create(:user))

        # add comment to photo
        comment = Factory.create(:comment, :commentable => commentable, :user => Factory.create(:user))

        # run the test
        comment.send_notification_emails


        ActionMailer::Base.deliveries.should have(3).things

        # expect email to album owner
        ActionMailer::Base.deliveries.should satisfy do |messages|
          messages.index { |message| message.to == [photo.album.user.email] }
        end

        # expect email to photo owner
        ActionMailer::Base.deliveries.should satisfy do |messages|
          messages.index { |message| message.to == [photo.user.email] }
        end

        # expect email to other commenters
        ActionMailer::Base.deliveries.should satisfy do |messages|
          messages.index { |message| message.to == [existing_comment.user.email] }
        end
      end
    end

    it "should notify all other people in the group of new comments" do
      resque_jobs(comments_resque_filter) do
        # setup
        photo_owner = Factory.create(:user)
        photo = Factory.create(:photo, :user => photo_owner)
        commentable = Commentable.find_or_create_by_photo_id(photo.id)

        # create users in group
        user_in_group = Factory.create(:user)
        user_in_group.save!

        # create users from email
        user_from_email = "user1@test.zangzing.com"

        # add users to group
        photo.album.add_contributors(user_in_group.my_group_id)
        viewer_user = User.create_automatic(user_from_email, '', true, photo_owner)
        photo.album.add_viewers(viewer_user.my_group_id)

        # add comment to photo. make commenter the photo owner so we don't get extra emails.
        comment = Factory.create(:comment, :commentable => commentable, :user => photo_owner)

        # run the test
        comment.send_notification_emails

        ActionMailer::Base.deliveries.should have(2).things

        # expect email to user in group
        ActionMailer::Base.deliveries.should satisfy do |messages|
          messages.index { |message| message.to == [user_in_group.email] }
        end

        # expect no email to user without an account since auto users have social emails turned off
        ActionMailer::Base.deliveries.should satisfy do |messages|
          messages.index { |message| message.to == [user_from_email] }
        end
      end
    end


    it "should post comment to facebook" do
      resque_jobs(comments_resque_filter) do
        comment = Factory.create(:photo_comment)
        comment.post_to_facebook

        FacebookPublisher.test_posts.should have(1).thing
        FacebookPublisher.test_posts[0][:message].should eql(comment.text)
      end
    end

    it "should post comment to twitter" do
      resque_jobs(comments_resque_filter) do
        comment = Factory.create(:photo_comment)
        comment.post_to_twitter

        TwitterPublisher.test_posts.should have(1).thing
        TwitterPublisher.test_posts[0].should satisfy{ |message| message.match(/^#{comment.text}/)}
      end
    end


    it "should create comment activity" do
      resque_jobs(comments_resque_filter) do
        comment = Factory.create(:photo_comment)
        photo = comment.commentable.subject

        comment.user.activities.length.should eql(1)
        comment_activity = comment.user.activities[0]
        comment_activity.should be_an_instance_of(CommentActivity)

        comment_activity.comment.should == comment

        comment_activity.subject.should == photo.album

        comment_activity.user.should == comment.user
      end
    end
  end







  describe Commentable do

    it "should return comments even if commenting user was deleted" do
      resque_jobs(comments_resque_filter) do
        commentable = Factory.create(:photo_commentable)
        commentable.comments << Factory.build(:comment)
        commentable.comments << Factory.build(:comment)
        commentable.save!

        # delete user
        commentable.comments.first.user.destroy

        # for some reasn, we need to re-fetch
        commentable = Commentable.find(commentable.id)

        # make sure we can still get comments (first coment will be filtered out because user is missing)
        puts commentable.comments_as_json.inspect
      end
    end

    it "should cache comment count" do
      resque_jobs(comments_resque_filter) do

        commentable = Factory.create(:photo_commentable)
        Factory.create(:comment, :commentable => commentable)
        Factory.create(:comment, :commentable => commentable)

        commentable = Commentable.find(commentable.id)
        commentable.comments.length.should eql(2)
        commentable.comments_count.should eql(2)
      end
    end

    it "should include user information in comment json" do
      resque_jobs(comments_resque_filter) do
        commentable = Factory.create(:photo_commentable)
        Factory.create(:comment, :commentable => commentable)
        Factory.create(:comment, :commentable => commentable)

        commentable = Commentable.find(commentable.id)
        commentable.comments.length.should eql(2)

        hash = commentable.comments_as_json

        hash['comments'][0]['user']['profile_photo_url'].should_not be_nil
        hash['comments'][0]['user']['name'].should_not be_nil
      end
    end

    it "should return comment metadata for all photos in album" do
      resque_jobs(comments_resque_filter) do
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
    end


    it 'should return comment metadata and comment details for photo' do
      resque_jobs(comments_resque_filter) do
        comment = Factory.create(:photo_comment)
        photo = comment.commentable.subject

        hash = Commentable.photo_comments_as_json(photo.id)
        hash['comments_count'].should eql(1)
        hash['comments'].length.should eql(1)
        hash['comments'][0]['text'].should eql(comment.text)
      end
    end

    it 'should return emtpy metadata and no comments if photo has no comments' do
      resque_jobs(comments_resque_filter) do
        hash = Commentable.photo_comments_as_json(Factory.create(:photo).id)
        hash.keys.length.should eql(0)
      end
    end

    it 'should allow searching by array of subject hashes; eg: [{:subject_id=>1,:subject_type=>"photo"}]' do
      resque_jobs(comments_resque_filter) do
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
end