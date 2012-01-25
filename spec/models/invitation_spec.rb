require 'spec_helper'

resque_filter = {:except => [ZZ::Async::MailingListSync]}


describe Invitation do

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  describe "#send_invitation_to_email" do

    it "should allow second invitation to same email address if first invitation joins under different address" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        address = 'test@zangzing.com'

        invitation = Invitation.create_and_send_invitation(user, address)
        user.sent_invitations.length.should == 1

        # accept invitation under differnt email address
        new_user_1 = Factory.create(:user, :email=> "test2@test.zangzing.com")
        Invitation.process_invitations_for_new_user(new_user_1, invitation.tracked_link.tracking_token)


        # send another invitation to same email address
        Invitation.create_and_send_invitation(user, address)


        # make sure we go back to db to get invitations...
        User.find(user.id).sent_invitations.length.should == 2

      end
    end

    it "should allow 2 users to send invitation to same email" do
      resque_jobs(resque_filter) do
        user_1 = Factory.create(:user)
        user_2 = Factory.create(:user)

        address = 'test@zangzing.com'

        Invitation.create_and_send_invitation(user_1, address)
        Invitation.create_and_send_invitation(user_2, address)

        user_1.sent_invitations.length.should == 1
        user_2.sent_invitations.length.should == 1

        ActionMailer::Base.deliveries.length.should == 2

      end
    end

    it "should allow sending invitation to 'automatic' users" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        automatic_user = Factory.create(:user, :email=>"test@test.zangzing.com", :automatic=>true)

        Invitation.create_and_send_invitation(user, automatic_user.email)

        user.sent_invitations.length.should == 1

        ActionMailer::Base.deliveries.length.should == 1

      end
    end

    it "should send email and create PENDING invitation" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        Invitation.create_and_send_invitation(user, 'test@test.zangzing.com')

        user.sent_invitations.length.should == 1

        ActionMailer::Base.deliveries.length.should == 1

      end
    end

    it "it should not create duplicate invitaions if called multiple times from same user to same email address" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        Invitation.create_and_send_invitation(user, 'test@test.zangzing.com')
        Invitation.create_and_send_invitation(user, 'test@test.zangzing.com')

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
        Invitation.get_invitation_link_for_copy_paste(user).should match(/http:\/\/localhost\/invitation\?ref=.*/i)
      end
    end
  end

  describe "#get_invitation_link_for_facebook" do
    it "should return correct url" do
      resque_jobs(resque_filter) do
        user = Factory.create(:user)
        Invitation.get_invitation_link_for_facebook(user).should match(/http:\/\/localhost\/invitation\?ref=.*/i)
      end
    end
  end

  describe "#get_invitation_link_for_twitter" do
    it "should return correct url" do
      resque_jobs(resque_filter) do

        user = Factory.create(:user)
        Invitation.get_invitation_link_for_twitter(user).should match(/http:\/\/localhost\/invitation\?ref=.*/i)
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

    it "more than one user should be ablet to join using the same invitation email" do
      from_user = Factory.create(:user)

      email_invitation = Invitation.create_invitation_for_email(from_user, 'test@test.zangzing.com')
      tracking_token = email_invitation.tracked_link.tracking_token

      new_user_1 = Factory.create(:user, :email => 'test@test.zangzing.com')
      new_user_2 = Factory.create(:user, :email => 'test2@test.zangzing.com')

      Invitation.process_invitations_for_new_user(new_user_1, tracking_token)
      Invitation.process_invitations_for_new_user(new_user_2, tracking_token)

      from_user.sent_invitations.length.should == 2



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
