require 'spec_helper'

resque_filter = {:except => [ZZ::Async::MailingListSync]}


describe InvitationsController do
  include PrettyUrlHelper
  include ControllerSpecHelper
  include ResponseActionsHelper

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


  describe '#send_reminder' do
    it "should work for pending invitation" do
      resque_jobs(resque_filter) do
        invitation = Invitation.create_invitation_for_email(@current_user, 'test@test.zangzing.com')

        xhr :post, :send_reminder, {:invitation_id => invitation.id}
        response.status.should be(200)
        ActionMailer::Base.deliveries.length.should == 1
      end
    end
  end

  describe '#send_to_email action' do
    it "should fail if no current user" do
      logout
      xhr :post, :send_to_email, {:emails => ['test@zangzing.com']}
      response.status.should be(401)
    end

    it "should send invitation emails to specified addresses" do
      resque_jobs(resque_filter) do
        xhr :post, :send_to_email, {:emails => ['test1@zangzing.com', 'test2@zangzing.com']}
        response.status.should be(200)
        ActionMailer::Base.deliveries.length.should == 2
      end
    end

    it "should reject emails that belong to existing zz users" do
      resque_jobs(resque_filter) do
        user_1 = Factory.create(:user, :email => 'test1@test.zangzing.com')
        user_2 = Factory.create(:user, :email => 'test2@test.zangzing.com')

        xhr :post, :send_to_email, {:emails => [user_1.email, user_2.email, 'test3@test.zangzing.com']}

        response.status.should be(200)

        # should reject 2 email addresses because they already belong to users
        body = JSON.parse(response.body)
        body['already_joined'].length.should == 2

        # should send email to 1 email that is not associated with user
        ActionMailer::Base.deliveries.length.should == 1

      end
    end
  end


end

