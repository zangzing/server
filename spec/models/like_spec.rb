require 'spec_helper'
require 'factory_girl'

comments_resque_filter = { :except => [ZZ::Async::MailingListSync] }

describe Like do

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end


  #it "should notify all members of group when album is liked" do
  #  resque_jobs(comments_resque_filter) do
  #    # setup
  #    user_who_likes = Factory.create(:user)
  #    album = Factory.create(:album)
  #    album_owner = album.user
  #    viewer_1 = Factory.create(:user)
  #    viewer_2 = Factory.create(:user)
  #    album.add_viewers([viewer_1.my_group_id, viewer_2.my_group_id])
  #
  #
  #    # like
  #    Like.add(user_who_likes.id, album.id, Like::ALBUM)
  #
  #
  #    # check that emails sent to group
  #    ActionMailer::Base.deliveries.length.should == 3
  #
  #    ActionMailer::Base.deliveries.should satisfy do |messages|
  #      messages.index { |message| [[album_owner.email], [viewer_1.email], [viewer_2.email]].include?(message.to)  }
  #    end
  #  end
  #end
  #
  #it "should notify all members of group when photo is liked" do
  #  resque_jobs(comments_resque_filter) do
  #    # setup
  #    user_who_likes = Factory.create(:user)
  #    album = Factory.create(:album)
  #    photo = Factory.create(:photo, :album => album)
  #    album_owner = album.user
  #    photo_owner = photo.user
  #    viewer_1 = Factory.create(:user)
  #    viewer_2 = Factory.create(:user)
  #    album.add_viewers([viewer_1.my_group_id, viewer_2.my_group_id])
  #
  #
  #    # like
  #    Like.add(user_who_likes.id, photo.id, Like::PHOTO)
  #
  #
  #    # check that emails sent to group
  #    ActionMailer::Base.deliveries.length.should == 4
  #
  #    ActionMailer::Base.deliveries.should satisfy do |messages|
  #      messages.index { |message| [[photo_owner.email], [album_owner.email], [viewer_1.email], [viewer_2.email]].include?(message.to)  }
  #    end
  #  end
  #end
end
