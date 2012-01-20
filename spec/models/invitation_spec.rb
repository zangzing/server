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

    it "it should not create duplicate invitaions if called multiple times from same user to same email address" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        Invitation.send_invitation_to_email(user, 'test@test.zangzing.com')
        Invitation.send_invitation_to_email(user, 'test@test.zangzing.com')

        user.sent_invitations.length.should == 1

        ActionMailer::Base.deliveries.length.should == 2

      end
    end


  end

  describe "#send_reminder" do
    it "should reminder email" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        invitation = Invitation.create_invitation_for_email(user, 'test@test.zangzing.com')
        Invitation.send_reminder(invitation.id)

        ActionMailer::Base.deliveries.length.should == 1

      end
    end
  end



  describe "#get_invitation_link_for_copy_paste" do
    it "should return correct url" do
      resque_jobs(resque_filter) do
        user = Factory.create(:user)
        Invitation.get_invitation_link_for_copy_paste(user).should match(/http:\/\/localhost\/invite\?ref=.*/i)
      end
    end
  end

  describe "#get_invitation_link_for_facebook" do
    it "should return correct url" do
      resque_jobs(resque_filter) do
        user = Factory.create(:user)
        Invitation.get_invitation_link_for_facebook(user).should match(/http:\/\/localhost\/invite\?ref=.*/i)
      end
    end
  end

  describe "#get_invitation_link_for_twitter" do
    it "should return correct url" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        Invitation.get_invitation_link_for_twitter(user).should match(/http:\/\/localhost\/invite\?ref=.*/i)
      end
    end
  end

  describe "#process_invitations_for_new_user" do
    it "should create new completed invitation and update user bonus storage for copy/paste invitation" do
      resque_jobs(resque_filter) do
        from_user = Factory.create(:user)
        to_user = Factory.create(:user)

        link = Invitation.get_invitation_link_for_copy_paste(from_user)

        params = CGI.parse(URI.parse(link).query).symbolize_keys

        tracking_token = params[:ref]

        Invitation.process_invitations_for_new_user(to_user, tracking_token)

        from_user.sent_invitations.length.should == 1
        to_user.received_invitations.length.should == 1

        to_user.received_invitations.first.status.should == Invitation::STATUS_COMPLETE

        ActionMailer::Base.deliveries.length.should == 2 # invite success email and follow email


        User.find(from_user.id).bonus_storage.should == User::BONUS_STORAGE_MB_PER_INVITE
        User.find(to_user.id).bonus_storage.should == User::BONUS_STORAGE_MB_PER_INVITE


       end
    end

    it "when no tracking token, it should find last invitation by email and invalidate the rest" do
      to_email = 'test@test.zangzing.com'
      Invitation.create_invitation_for_email(Factory.create(:user), to_email)
      Invitation.create_invitation_for_email(Factory.create(:user), to_email)
      Invitation.create_invitation_for_email(Factory.create(:user), to_email)
      Invitation.create_invitation_for_email(Factory.create(:user), to_email)

      new_user = Factory.create(:user, :email => to_email)

      Invitation.process_invitations_for_new_user(new_user, nil)

      invitations = Invitation.find(:all, :conditions=>{:email=>to_email})

      invitations[0].status.should == Invitation::STATUS_COMPLETE_BY_OTHER
      invitations[1].status.should == Invitation::STATUS_COMPLETE_BY_OTHER
      invitations[2].status.should == Invitation::STATUS_COMPLETE_BY_OTHER
      invitations[3].status.should == Invitation::STATUS_COMPLETE

    end

  end
end
