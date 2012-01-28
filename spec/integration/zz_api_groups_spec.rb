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
    def get_matching_user(compare, symbol, members)
      members.each do |member|
        user = member[:user]
        return user if compare == user[symbol]
      end
      return nil
    end

    # return true if item matches based on symbol
    def is_matching_user?(compare, symbol, members)
      !!get_matching_user(compare, symbol, members)
    end

    it "should create, add a member of each kind, and delete all users" do
      group_name = "mytestgroup"
      j = zz_api_post zz_api_create_group_path, {:name => group_name}, 200
      j[:name].should == group_name
      group_id = j[:id]

      user1 = Factory.create(:user)
      names = [user1.username]
      user2 = Factory.create(:user)
      ids = [user2.id]
      last_name = "groupopolos_#{rand(99999)}"
      email_only = "group_member1@grouptest.com"
      emails = ["Group #{last_name} <#{email_only}>"]

      j = zz_api_post zz_api_add_members_group_path(group_id), {:user_ids => ids, :emails => emails, :user_names => names}, 200
      j.length.should == 3
      members = j

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
      members = zz_api_post zz_api_add_members_group_path(group_id), {:user_ids => ids, :emails => emails, :user_names => names}, 200
      members.length.should == 3

      is_matching_user?(names[0], :username, members).should == true
      is_matching_user?(ids[0], :id, members).should == true
      is_matching_user?(last_name, :last_name, members).should == true

      # this time they should all have emails set
      is_matching_user?(user1.email, :email, members).should == true
      is_matching_user?(user2.email, :email, members).should == true
      is_matching_user?(email_only, :email, members).should == true

      # now delete them
      delete_ids = members.map {|member| member[:user][:id]}
      zz_api_post zz_api_remove_members_group_path(group_id), {:user_ids => delete_ids}, 200

      # verify nothing left
      j = zz_api_get zz_api_members_group_path(group_id), 200
      j.length.should == 0
    end

    describe "ACL" do
      def verify_tuples(tuples, expected)
        tuples.length.should == expected.length
        tuples.each do |tuple|
          expected.include?(tuple.acl_id).should == true
        end
      end

      it "should assign user to ACL and verify permission" do
        album = Factory.create(:album)
        user = album.user
        acl = AlbumACL.new(album.id)
        acl2 = AlbumACL.new(Factory.create(:album, :user => user).id)
        acl3 = AlbumACL.new(Factory.create(:album, :user => user).id)

        acl.add_user(user, AlbumACL::CONTRIBUTOR_ROLE)
        acl.has_permission?(user.id, AlbumACL::CONTRIBUTOR_ROLE).should == true
        acl.has_permission?(user.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user.id, AlbumACL::VIEWER_ROLE).should == true
        acl.has_permission?(user.id, AlbumACL::VIEWER_ROLE, true).should == false
        acl.has_permission?(user.id, AlbumACL::ADMIN_ROLE).should == false

        # make sure user has expected role
        acl.get_user_role(user.id).should == AlbumACL::CONTRIBUTOR_ROLE
        user_ids = acl.get_users_with_role(AlbumACL::CONTRIBUTOR_ROLE)
        user_ids[0].should == user.id

        # upgrade to ADMIN
        acl.add_user(user, AlbumACL::ADMIN_ROLE)
        acl.has_permission?(user.id, AlbumACL::ADMIN_ROLE).should == true
        acl.has_permission?(user.id, AlbumACL::CONTRIBUTOR_ROLE).should == true
        acl.has_permission?(user.id, AlbumACL::VIEWER_ROLE).should == true
        acl.has_permission?(user.id, AlbumACL::VIEWER_ROLE, true).should == false

        # now remove the user and test
        acl.remove_user(user)
        acl.has_permission?(user.id, AlbumACL::ADMIN_ROLE).should == false
        acl.has_permission?(user.id, AlbumACL::CONTRIBUTOR_ROLE).should == false
        acl.has_permission?(user.id, AlbumACL::VIEWER_ROLE).should == false

        acl.add_user(user, AlbumACL::CONTRIBUTOR_ROLE)
        acl2.add_user(user, AlbumACL::VIEWER_ROLE)
        acl3.add_user(user, AlbumACL::ADMIN_ROLE)
        tuples = AlbumACL.get_acls_for_user(user.id, AlbumACL::CONTRIBUTOR_ROLE, false)
        verify_tuples(tuples, [acl.acl_id, acl3.acl_id])
        tuples = AlbumACL.get_acls_for_user(user.id, AlbumACL::CONTRIBUTOR_ROLE, true)
        verify_tuples(tuples, [acl.acl_id])
        tuples = AlbumACL.get_all_acls_for_user(user.id)
        verify_tuples(tuples, [acl.acl_id, acl2.acl_id, acl3.acl_id])
      end


      it "should assign group to ACL and verify permission" do
        album = Factory.create(:album)
        user1 = album.user
        user2 = Factory.create(:user)
        user3 = Factory.create(:user)
        user4 = Factory.create(:user)

        group1 = Group.create(:user_id => user1.id, :name => 'group_u1_g1')
        group1a = Group.create(:user_id => user1.id, :name => 'group_u1_g1a')
        group2 = Group.create(:user_id => user2.id, :name => 'group_u2_g1')
        group3 = Group.create(:user_id => user3.id, :name => 'group_u3_g1')

        # assign users to groups
        rows = [
            [group1.id, user1.id],
            [group1.id, user3.id],

            [group1a.id, user2.id],
            [group1a.id, user3.id],

            [group2.id, user1.id],
            [group2.id, user4.id],

            [group3.id, user1.id],
            [group3.id, user2.id],
            [group3.id, user3.id],
            [group3.id, user4.id],
        ]
        GroupMember.fast_update_members(rows)

        acl2 = AlbumACL.new(Factory.create(:album, :user => user2).id)
        acl3 = AlbumACL.new(Factory.create(:album, :user => user3).id)

        acl = AlbumACL.new(album.id)
        acl.add_group(group1.id, AlbumACL::CONTRIBUTOR_ROLE)
        acl.has_permission?(user1.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user2.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false
        acl.has_permission?(user3.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user4.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false
        # make sure group has expected role
        acl.get_group_role(group1.id).should == AlbumACL::CONTRIBUTOR_ROLE

        # verify that groups have permissions
        acl.group_has_permission?(group1.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.group_has_permission?(group1a.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false
        acl.group_has_permission?(group2.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false
        acl.group_has_permission?(group3.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false


        # now add group 1a so we should have 1,2,3
        acl.add_group(group1a.id, AlbumACL::CONTRIBUTOR_ROLE)
        acl.has_permission?(user1.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user2.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user3.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user4.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false

        # now downgrade group1a to viewer
        acl.add_group(group1a.id, AlbumACL::VIEWER_ROLE)
        acl.has_permission?(user1.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user2.id, AlbumACL::VIEWER_ROLE, true).should == true
        acl.has_permission?(user3.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user4.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false

        # now remove the group
        acl.remove_group(group1a.id)
        acl.has_permission?(user1.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user2.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false
        acl.has_permission?(user3.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user4.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false
        # add it back
        acl.add_group(group1a.id, AlbumACL::VIEWER_ROLE)

        # now delete a group without removing from acl
        #todo need to add cleanup code to group to remove self from acls and verify
        group1a.destroy
        acl.has_permission?(user1.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user2.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false
        acl.has_permission?(user3.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user4.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == false

        acl.add_group(group2.id, AlbumACL::ADMIN_ROLE)
        acl.add_group(group3.id, AlbumACL::VIEWER_ROLE)
        acl.has_permission?(user1.id, AlbumACL::ADMIN_ROLE, true).should == true
        acl.has_permission?(user2.id, AlbumACL::VIEWER_ROLE, true).should == true
        acl.has_permission?(user3.id, AlbumACL::CONTRIBUTOR_ROLE, true).should == true
        acl.has_permission?(user4.id, AlbumACL::ADMIN_ROLE, true).should == true

        group_ids = acl.get_groups_with_role(AlbumACL::ADMIN_ROLE)
        group_ids.length.should == 1
        group_ids.include?(group2.id).should == true

        user_ids = acl.get_users_with_role(AlbumACL::ADMIN_ROLE)
        user_ids.length.should == 2
        user_ids.include?(user1.id).should == true
        user_ids.include?(user4.id).should == true

        group_ids = acl.get_groups_with_role(AlbumACL::VIEWER_ROLE)
        group_ids.length.should == 3
        group_ids.include?(group1.id).should == true
        group_ids.include?(group2.id).should == true
        group_ids.include?(group3.id).should == true

        acl2.add_group(group2.id, AlbumACL::VIEWER_ROLE)
        acl3.add_group(group2.id, AlbumACL::CONTRIBUTOR_ROLE)
        acl3.add_group(group3.id, AlbumACL::ADMIN_ROLE)
        tuples = AlbumACL.get_acls_for_group(group1.id, AlbumACL::CONTRIBUTOR_ROLE, false)
        verify_tuples(tuples, [acl.acl_id])
        tuples = AlbumACL.get_acls_for_group(group2.id, AlbumACL::VIEWER_ROLE, true)
        verify_tuples(tuples, [acl2.acl_id])
        tuples = AlbumACL.get_all_acls_for_group(group2.id)
        verify_tuples(tuples, [acl.acl_id, acl2.acl_id, acl3.acl_id])

        #todo notes
        # need to modify groups class to invalidate caches when membership of a group changes
        # have to decide if we simply notify all the users changed, or only the ones that
        # were tied to one or more acls.  Probably easiest for now just to notify all changed when adding or
        # removing members from a group or removing the whole group
        # need to see about collecting all invalidations into a batch and then invalidating the cache
        # in one or few calls rather than one per invalidation
        #
        # need to modify cache notification to take multiple notifies
        #
      end
    end
end