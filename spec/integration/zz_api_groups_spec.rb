require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

describe "ZZ API Groups" do

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

    it "should create a group" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      j = zz_api_get zz_api_info_group_path(j[:id]), 200
      j[:name].should == group_name
      # get all groups by this user
      j = zz_api_get zz_api_users_groups_path, 200
      j.length.should == 1    # group just created and wrapped group
      j[0][:name].should == group_name
    end

    it "should get the wrapped user group" do
      group_name = Group.make_wrapped_name(@user_id)
      j = zz_api_get zz_api_info_group_path(group_name), 200
      j[:name].should == group_name
      j[:user][:id].should == @user_id
    end

    it "should delete a group" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      zz_api_post zz_api_destroy_group_path(j[:id]), nil, 200
      j = zz_api_get zz_api_info_group_path(j[:id]), 404
    end

    it "should update a group and fail to insert duplicate" do
      group_name = "mytestgroup"
      new_group_name = "renamed group"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      j = zz_api_post zz_api_update_group_path(j[:id]), {:name => new_group_name}, 200
      j[:name].should == new_group_name
      # should fail to create a duplicate group
      j = zz_api_post zz_api_create_group_path, {:name => new_group_name}, 409
    end

    it "should create a group and add username members" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      group_id = j[:id]

      users = []
      names = []
      3.times do |i|
        user = Factory.create(:user)
        users << user
        names << user.username
      end
      j = zz_api_post zz_api_add_members_group_path(group_id), {:user_names => names}, 200
      j.length.should == names.length
      members = j

      # do it again, this time should return the same users
      j = zz_api_post zz_api_add_members_group_path(group_id), {:user_names => names}, 200
      j.length.should == names.length
      j.length.times do |i|
        j[i][:user][:username].should == members[i][:user][:username]
      end
    end

    it "should create a group and add userid members" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      group_id = j[:id]

      users = []
      ids = []
      3.times do |i|
        user = Factory.create(:user)
        users << user
        ids << user.id
      end
      j = zz_api_post zz_api_add_members_group_path(group_id), {:user_ids => ids}, 200
      j.length.should == ids.length
      members = j

      # do it again, this time should return the same users
      j = zz_api_post zz_api_add_members_group_path(group_id), {:user_ids => ids}, 200
      j.length.should == ids.length
      j.length.times do |i|
        j[i][:user][:id].should == members[i][:user][:id]
      end
    end

    it "should create a group and add email members" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      group_id = j[:id]

      emails = ['Group User1 <group_member1@grouptest.com>', 'Group User2 <group_member2@grouptest.com>', 'Group User3 <group_member3@grouptest.com>']
      j = zz_api_post zz_api_add_members_group_path(group_id), {:emails => emails}, 200
      j.length.should == emails.length
      members = j

      # do it again, this time should return the same users
      j = zz_api_post zz_api_add_members_group_path(group_id), {:emails => emails}, 200
      j.length.should == emails.length
      j.length.times do |i|
        j[i][:user][:id].should == members[i][:user][:id]
      end
    end

    it "should create, add members, and delete the group, leaving no members" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      group_id = j[:id]

      users = []
      ids = []
      3.times do |i|
        user = Factory.create(:user)
        users << user
        ids << user.id
      end
      j = zz_api_post zz_api_add_members_group_path(group_id), {:user_ids => ids}, 200
      j.length.should == ids.length
      members = j

      # now delete the group
      zz_api_post zz_api_destroy_group_path(group_id), nil, 200
      j = zz_api_get zz_api_info_group_path(group_id), 404

      # verify that items have been removed from the database
      members = GroupMember.find_all_by_group_id(group_id)
      members.length.should == 0
    end

    # return true if item matches based on symbol
    def is_matching_user?(compare, symbol, members)
      members.each do |member|
        user = member[:user]
        return true if compare == user[symbol]
      end
      return false
    end

    it "should create, add a member of each kind, and delete all users" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      group_id = j[:id]

      names = [Factory.create(:user).username]
      ids = [Factory.create(:user).id]
      last_name = "groupopolos_#{rand(99999)}"
      emails = ["Group #{last_name} <group_member1@grouptest.com>"]

      j = zz_api_post zz_api_add_members_group_path(group_id), {:user_ids => ids, :emails => emails, :user_names => names}, 200
      j.length.should == 3
      members = j

      is_matching_user?(names[0], :username, members).should == true
      is_matching_user?(ids[0], :id, members).should == true
      is_matching_user?(last_name, :last_name, members).should == true

      # now delete them
      delete_ids = members.map {|member| member[:user][:id]}
      zz_api_post zz_api_remove_members_group_path(group_id), {:user_ids => delete_ids}, 200

      # verify nothing left
      j = zz_api_get zz_api_members_group_path(group_id), 200
      j.length.should == 0
    end

end