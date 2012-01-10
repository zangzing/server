require 'spec_helper'

resque_filter = {:except => [ZZ::Async::MailingListSync]}


describe Invitation do

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  describe "#send_invitation_to_email" do
    it "should send email and create PENDING invitation" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        Invitation.send_invitation_to_email(user, 'test@test.zangzing.com')

        user.sent_invitations.length.should == 1

        ActionMailer::Base.deliveries.length.should == 1

      end
    end
  end

  describe "#get_invitation_link_for_copy_paste" do
    it "should return correct url" do
      resque_jobs(resque_filter) do
        user = Factory.create(:user)
        TrackedLink.set_test_token('test_token')
        Invitation.get_invitation_link_for_copy_paste(user).should == 'http://localhost/invite?ref=test_token'
      end
    end
  end

  describe "#get_invitation_link_for_facebook" do
    it "should return correct url" do
      resque_jobs(resque_filter) do
        user = Factory.create(:user)
        TrackedLink.set_test_token('test_token')
        Invitation.get_invitation_link_for_facebook(user).should == 'http://localhost/invite?ref=test_token'
      end
    end
  end

  describe "#get_invitation_link_for_twitter" do
    it "should return correct url" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        TrackedLink.set_test_token('test_token')
        Invitation.get_invitation_link_for_twitter(user).should == 'http://localhost/invite?ref=test_token'
      end
    end
  end

  describe "#handle_join_from_invitation" do
    it "should create new completed invitation for copy/paste invitation" do
      resque_jobs(resque_filter) do
        from_user = Factory.create(:user)
        to_user = Factory.create(:user)

        link = Invitation.get_invitation_link_for_copy_paste(from_user)

        params = CGI.parse(URI.parse(link).query).symbolize_keys

        tracking_token = params[:ref]

        Invitation.handle_join_from_invitation(to_user, tracking_token)

        from_user.sent_invitations.length.should == 1
        to_user.received_invitations.length.should == 1

        to_user.received_invitations.first.status.should == Invitation::STATUS_COMPLETE

        ActionMailer::Base.deliveries.length.should == 1

      end
    end
  end
end
