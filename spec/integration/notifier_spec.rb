require 'spec_helper'

describe Notifier do


  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end


  describe 'Send Events' do
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
      end
    end
    
    it "should send phtos_ready upon batch completion" do
      pending "not implemented yet"
    end

    it "shoud send password_reset upon user request" do
      pending "not implemented yet"
    end
  end

end