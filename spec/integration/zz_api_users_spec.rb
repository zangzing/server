require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

describe "ZZ API Users" do

    before(:each) do
      @user_id = zz_login("test1", "testtest")
      @user = User.find(@user_id)
    end

    before(:all) do
      @@old_debug_state = zz_api_debug(false)
    end
    after(:all) do
      zz_api_debug(@@old_debug_state)
    end


    it "should fail to get user info" do
      j = zz_api_get zz_api_user_info_path(99999999), 509
      #puts JSON.pretty_generate(j)
      j[:message].should == "Couldn't find User with ID=99999999"
    end

    it "should get user info" do
      j = zz_api_get zz_api_user_info_path(@user_id), 200
      #puts JSON.pretty_generate(j)
      j[:username].should == 'test1'
    end

    # return true if item matches based on symbol
    def get_matching_user(compare, symbol, members)
      members.each do |user|
        return user if compare == user[symbol]
      end
      return nil
    end

    # return true if item matches based on symbol
    def is_matching_user?(compare, symbol, members)
      !!get_matching_user(compare, symbol, members)
    end

    it "should find and create users" do
      user1 = Factory.create(:user)
      dont_find_user = 'neverfindthisuser'
      names = [user1.username, dont_find_user]
      user2 = Factory.create(:user)
      dont_find_id = 99999999999999
      ids = [user2.id, dont_find_id]  # the bogus id should not cause failure but should end up in missing list
      last_name = "SomeUser_#{rand(99999)}"
      email_only = "joe_some_user99@usertest.com"
      emails = ["Joe #{last_name} <#{email_only}>"]

      j = zz_api_post zz_api_find_or_create_user_path, {:user_ids => ids, :emails => emails, :user_names => names}, 200
      members = j[:users]
      members.length.should == 3
      missing = j[:not_found]
      missing_ids = missing[:user_ids]
      missing_user_names = missing[:user_names]
      missing_ids[0][:token].should == dont_find_id
      missing_ids[0][:index].should == 1
      missing_user_names[0][:token].should == dont_find_user
      missing_user_names[0][:index].should == 1

      is_matching_user?(names[0], :username, members).should == true
      is_matching_user?(ids[0], :id, members).should == true
      is_matching_user?(last_name, :last_name, members).should == true

      # make sure email exists on the auto user
      is_matching_user?(email_only, :email, members).should == true
      # and should not exist on the other two
      user = get_matching_user(names[0], :username, members)
      user[:email].should == nil
      user = get_matching_user(ids[0], :id, members)
      user[:email].should == nil

      # Now call again but this time only using emails.  In this case they should all return the extra email field
      emails = [user1.email, user2.email, email_only]
      j = zz_api_post zz_api_find_or_create_user_path, {:user_ids => ids, :emails => emails, :user_names => names}, 200
      members = j[:users]
      members.length.should == 3

      is_matching_user?(names[0], :username, members).should == true
      is_matching_user?(ids[0], :id, members).should == true
      is_matching_user?(last_name, :last_name, members).should == true

      # this time they should all have emails set
      is_matching_user?(user1.email, :email, members).should == true
      is_matching_user?(user2.email, :email, members).should == true
      is_matching_user?(email_only, :email, members).should == true

    end

end