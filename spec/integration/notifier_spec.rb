require 'spec_helper'

describe Notifier do

    before(:each) do
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end

    it "shoud send password_reset upon user request" do
        resque_jobs(:except => [ZZ::Async::MailingListSync]) do
        user = Factory.create(:user)
        visit new_password_reset_url
        fill_in 'email', :with    => user.email
        submit_form 'password_reset_form'
        response.status.should be 200
        ActionMailer::Base.deliveries.count.should == 1
        ActionMailer::Base.deliveries[0].header['X-SMTPAPI'].value.should include "email.password"
        end
      end


    it "should send welcome upon join" do
      resque_jobs(:except => [ZZ::Async::MailingListSync]) do
        visit join_url
        fill_in 'user[name]', :with     => Faker::Name.name
        fill_in 'user[username]', :with => Faker::Name.first_name.downcase
        fill_in 'user[email]', :with    => Faker::Internet.email
        fill_in 'user[password]', :with => 'password'
        submit_form 'join-form'
        response.status.should be 200
        ActionMailer::Base.deliveries.count.should == 1
        ActionMailer::Base.deliveries[0].header['X-SMTPAPI'].value.should include "email.welcome"
      end
    end

    it "should send photos_ready upon batch completion" do
      resque_jobs(:except => [ZZ::Async::MailingListSync]) do
            photo = Factory.create(:full_photo)
            photo.reload
            photo.ready?.should == true
            upload_batch = photo.upload_batch
            upload_batch.finish( true, true ) #force and notify
            upload_batch.state.should == "finished"
            ActionMailer::Base.deliveries.count.should == 1
            ActionMailer::Base.deliveries[0].header['X-SMTPAPI'].value.should include "email.photosready"
         end
    end


    it "should send user_liked when somebody start following you" do
      pending "not implemented yet"
    end

    it "should send album_liked when somebody likes your album" do
      pending "not implemented yet"
    end

    it "should send photo_liked when somebody likes your photo" do
      pending "not implemented yet"
    end

    it "should send album_updated when you like an album" do
      pending "not implemented yet"
    end

    it "should send album_updated when you follow someone" do
      pending "not implemented yet"
    end

    it "should send album_updated when you are a contributor" do
      pending "not implemented yet"
    end

    it "should send album_updated when you are a member of a streaming album" do
      pending "not implemented yet"
    end

    it "should send contributor_added when you are invited to contribute into an album" do
      pending "not implemented yet"
    end

    it "should send album_shared when someone shares an album by email with you" do
      pending "not implemented yet"
    end

    it "should send album_shared when someone invites you into an album as  viewer " do
      pending "not implemented yet"
    end

    it "should send photo_shared when someone shares a photo by email with you" do
      pending "not implemented yet"
    end

    it "should send photo_comment to onwer of photo when someone comments"  do
      pending "not implemented yet"
    end

    it "should send photo_comment to fellow photo commenters of photo when someone comments"  do
      pending "not implemented yet"
    end

    it "should send photo_comment to likers of photo" do
          pending "not implemented yet"
    end

    it "should NOT send photo_comment to commenters not in the ACL for a photo in a private album" do
      pending "not implemented yet"
    end
    ########################


end