require 'spec_helper'
require 'test_utils'

resque_filter = {:except => [ZZ::Async::MailingListSync]}

include PrettyUrlHelper

describe "ZZ API Shares" do

  before(:each) do
    @user_id = zz_login("test1", "testtest")
    @user = User.find(@user_id)
    @album_id = 29900073736   # from seed data
    @photo_id = 169911075733  # from seed data

    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def match_delivered_email(email, type)
    ActionMailer::Base.deliveries.should satisfy do |messages|
      messages.index { |message|
        message.to == [email] && message.header['X-SMTPAPI'].value.include?(type)
      }
    end
  end

  it "should send a viewer album share" do
    resque_jobs(resque_filter) do

      email_user = 'email_user1@bitbucket.zangzing.com'
      message = 'album_share_message'
      u1 = Factory.create(:user)
      share = {
          :emails => [email_user],
          :group_ids => [u1.my_group_id],
          :message => message,
          :share_type => Share::TYPE_VIEWER_INVITE,
          :album_id => @album_id
      }
      j = zz_api_post zz_api_send_share_path, share, 200
      j[:delayed].should == false
      ActionMailer::Base.deliveries.length.should == 2
      expected_type = 'email.albumshared'
      match_delivered_email(email_user, expected_type)
      match_delivered_email(u1.email, expected_type)
    end
  end

  it "should send a contributor album share" do
    resque_jobs(resque_filter) do

      email_user = 'email_user1@bitbucket.zangzing.com'
      message = 'album_share_message'
      u1 = Factory.create(:user)
      share = {
          :emails => [email_user],
          :group_ids => [u1.my_group_id],
          :message => message,
          :share_type => Share::TYPE_CONTRIBUTOR_INVITE,
          :album_id => @album_id
      }
      j = zz_api_post zz_api_send_share_path, share, 200
      j[:delayed].should == false
      ActionMailer::Base.deliveries.length.should == 2
      expected_type = 'email.contributorinvite'
      match_delivered_email(email_user, expected_type)
      match_delivered_email(u1.email, expected_type)
    end
  end

  it "should send a photo share" do
    resque_jobs(resque_filter) do

      email_user = 'email_user1@bitbucket.zangzing.com'
      message = 'album_share_message'
      u1 = Factory.create(:user)
      share = {
          :emails => [email_user],
          :group_ids => [u1.my_group_id],
          :message => message,
          :share_type => Share::TYPE_VIEWER_INVITE,
          :facebook => true,
          :twitter => true,
          :photo_id => @photo_id
      }
      identity = @user.identity_for_facebook
      identity.credentials = 'anything'
      identity.save!
      identity = @user.identity_for_twitter
      identity.credentials = 'anything'
      identity.save!

      # test deferred photo share
      j = zz_api_post zz_api_send_share_path, share, 200
      j[:delayed].should == false
      ActionMailer::Base.deliveries.length.should == 2
      expected_type = 'email.photoshared'
      match_delivered_email(email_user, expected_type)
      match_delivered_email(u1.email, expected_type)

      # now look to see if the shares got created for facebook and twitter
      s = Share.find_by_user_id_and_service_and_message(@user_id, 'social', message)
      s.should_not == nil
      s.recipients.should include('facebook')
      s.recipients.should include('twitter')
    end
  end

  it "should defer deliver a photo share" do
    resque_jobs(resque_filter) do

      email_user = 'email_user1@bitbucket.zangzing.com'
      message = 'album_share_message'
      u1 = Factory.create(:user)
      photo = Factory.create(:photo, :user => @user)

      share = {
          :emails => [email_user],
          :group_ids => [u1.my_group_id],
          :message => message,
          :share_type => Share::TYPE_VIEWER_INVITE,
          :facebook => true,
          :twitter => true,
          :photo_id => photo.id
      }
      identity = @user.identity_for_facebook
      identity.credentials = 'anything'
      identity.save!
      identity = @user.identity_for_twitter
      identity.credentials = 'anything'
      identity.save!

      # test deferred photo share
      j = zz_api_post zz_api_send_share_path, share, 200
      j[:delayed].should == true
      ActionMailer::Base.deliveries.length.should == 0

      photo.deliver_shares  # force it to deliver deferred shares

      # now they should be delivered
      ActionMailer::Base.deliveries.length.should == 2
      expected_type = 'email.photoshared'
      match_delivered_email(email_user, expected_type)
      match_delivered_email(u1.email, expected_type)

      # now look to see if the shares got created for facebook and twitter
      s = Share.find_by_user_id_and_service_and_message(@user_id, 'social', message)
      s.should_not == nil
      s.recipients.should include('facebook')
      s.recipients.should include('twitter')
    end
  end

  it "should fail on bad identity" do
    resque_jobs(resque_filter) do

      email_user = 'email_user1@bitbucket.zangzing.com'
      message = 'album_share_message'
      u1 = Factory.create(:user)
      share = {
          :emails => [email_user],
          :group_ids => [u1.my_group_id],
          :message => message,
          :share_type => Share::TYPE_VIEWER_INVITE,
          :facebook => false,
          :twitter => true,
          :photo_id => @photo_id
      }

      j = zz_api_post zz_api_send_share_path, share, 509
      j[:message].should == 'twitter identity is not valid'
    end
  end

  it "should send a user share" do
    resque_jobs(resque_filter) do

      email_user = 'email_user1@bitbucket.zangzing.com'
      message = 'album_share_message'
      u1 = Factory.create(:user)
      share = {
          :emails => [email_user],
          :group_ids => [u1.my_group_id],
          :message => message,
          :share_type => Share::TYPE_VIEWER_INVITE,
          :user_id => @user_id
      }
      j = zz_api_post zz_api_send_share_path, share, 200
      j[:delayed].should == false
      ActionMailer::Base.deliveries.length.should == 0
    end
  end

end