require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

describe "ZZ API Groups" do

    before(:each) do
      @user_id = zz_login("test1", "testtest")
      @user = User.find(@user_id)
    end

    it "should create a group" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      j = zz_api_get zz_api_info_group_path(j[:id]), 200
      j[:name].should == group_name
    end

    it "should delete a group" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      zz_api_delete zz_api_destroy_group_path(j[:id]), nil, 200
      j = zz_api_get zz_api_info_group_path(j[:id]), 404
    end

    it "should update a group and fail to insert duplicate" do
      group_name = "mytestgroup"
      new_group_name = "renamed group"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      j = zz_api_put zz_api_update_group_path(j[:id]), {:name => new_group_name}, 200
      j[:name].should == new_group_name
      # should fail to create a duplicate group
      j = zz_api_post zz_api_create_group_path, {:name => new_group_name}, 409
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
    end

end