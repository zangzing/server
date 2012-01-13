require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

describe "ZZ API Groups" do

    before(:each) do
      @user_id = zz_login("test1", "testtest")
      @user = User.find(@user_id)
    end

    it "should create and validate wrapped user" do
      username = "grouptestuser"
      email = "groupuser@grouptest.com"
      user = Factory.create(:user, :username => username, :email => email)

      j = zz_api_put zz_api_wrap_user_group_path, {:email => "groupuser@grouptest.com"}, 200
      j[:member_info][:user][:username].should == username
      group_id = j[:id]
      member_id = j[:member_info][:id]

      # now call again, this time via user id, should fetch already created one
      j = zz_api_put zz_api_wrap_user_group_path, {:user_id => user.id}, 200
      j[:member_info][:user][:username].should == username
      j[:id].should == group_id
      j[:member_info][:id].should == member_id

      j[:public].should == false
      j[:logged_in_user_id].should == @user_id
    end

end