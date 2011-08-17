require 'spec_helper'
require 'factory_girl'


describe CommentActivity do

  describe "visibility" do

    before(:each) do
      @comment = Factory.create(:photo_comment)
      @album  = @comment.commentable.subject.album
      @some_user = Factory(:user)
      @group_member = Factory.create(:user)
      @album.add_viewer(@group_member.email)
      @album.save!
    end

    

    context "given public album" do
      before(:each) do
        @album.make_public
        @album.save!
      end

      context "given album's timeline view" do
        it "should be visible to all zangzing users" do
          @album.activities[0].display_for?(@some_user, Activity::ALBUM_VIEW).should be true
        end

        it "should be visible to all guest users" do
          @album.activities[0].display_for?(nil, Activity::ALBUM_VIEW).should be true
        end
      end

      context "given commenter's homepage timeline view" do
        it "should be visible to all registered users" do
          @comment.user.activities[0].display_for?(@some_user, Activity::USER_VIEW).should be true
        end

        it "should be visible to all guest users" do
          @comment.user.activities[0].display_for?(nil, Activity::USER_VIEW).should be true
        end

      end

    end


    context 'given hidden album' do
      before(:each) do
        @album.make_hidden
        @album.save!
      end

      context "given the album's timeline view" do
        it "should be visible to all registered users" do
          @album.activities[0].display_for?(@some_user, Activity::ALBUM_VIEW).should be true
        end

        it "should be visible to all guest users" do
          @album.activities[0].display_for?(@some_user, Activity::ALBUM_VIEW).should be true
        end
      end

      context "given the commenter's homepage timeline view" do
        it "should not be visible to all registered users" do
          @comment.user.activities[0].display_for?(@some_user, Activity::USER_VIEW).should be false
        end

        it "should not be visible to guest users" do
          @comment.user.activities[0].display_for?(nil, Activity::USER_VIEW).should be false
        end

        it "should be visible to registered users who are in album's group" do
          @comment.user.activities[0].display_for?(@group_member, Activity::USER_VIEW).should be true
        end

      end



    end

    context 'given private album' do
      before(:each) do
        @album.make_private
        @album.save!
      end

      context "given albums's timeline view" do
        it "should not be visible to registered users who are not in album's group" do
          @album.activities[0].display_for?(@some_user, Activity::ALBUM_VIEW).should be true
        end

        it "should not be visible to guest users" do
          @album.activities[0].display_for?(nil, Activity::ALBUM_VIEW).should be true
        end

        it "should be visible to registered user who is in album's group" do
          @album.activities[0].display_for?(@group_member, Activity::ALBUM_VIEW).should be true
        end



      end

      context "given commenter's homepage timeline view" do
        it "should not be visible to all registered users" do
          @comment.user.activities[0].display_for?(@some_user, Activity::USER_VIEW).should be false
        end

        it "should not be visible to guest users" do
          @comment.user.activities[0].display_for?(nil, Activity::USER_VIEW).should be false
        end

        it "should be visible to registered users who are in album's group" do
          @comment.user.activities[0].display_for?(@group_member, Activity::USER_VIEW).should be true
        end
      end
    end
  end
end
