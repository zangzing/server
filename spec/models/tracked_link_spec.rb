require 'spec_helper'

describe TrackedLink do

  describe "TrackedLink.create_tracked_link" do

    it "should fail after n times if it can't create unique token" do
      begin
        user = Factory.create(:user)

        # create same token each time to force collision
        TrackedLink.set_test_token("test_token")

        # this one will pass because this is the first one
        TrackedLink.create_tracked_link(user, 'http://www.zangzing.com', TrackedLink::TYPE_INVITATION, TrackedLink::SHARED_TO_FACEBOOK)


        # collision here should cause exception
        lambda {
          TrackedLink.create_tracked_link(user, 'http://www.zangzing.com', TrackedLink::TYPE_INVITATION, TrackedLink::SHARED_TO_FACEBOOK)
        }.should raise_error(ActiveRecord::RecordNotUnique)


      ensure
        # prevent this test from affecting others
        TrackedLink.set_test_token(nil)
      end


    end
  end
end
