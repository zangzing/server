require 'spec_helper'
require 'test_utils'

resque_filter = {:except => [ZZ::Async::MailingListSync]}

include PrettyUrlHelper

describe "ZZ API Albums" do

  describe "credentials" do
    it "should fail to login" do
      j = zz_api_post zz_api_login_path, {:email => "test1", :password => "badpassword"}, 401, true
    end

    it "should login" do
      login_info = zz_api_post zz_api_login_path, {:email => "test1", :password => "testtest"}, 200, true
      uid = login_info[:user_id]
      uid.should_not == nil
    end
  end

  describe "albums" do
    before(:each) do
      @user_id = zz_login("test1", "testtest")
      @user = User.find(@user_id)
    end

    it "should fetch albums and verify liked_user_albums_path and invited_users_path" do
      j = zz_api_get zz_api_albums_path(@user_id), 200
      j[:public].should == false
      j[:logged_in_user_id].should == @user_id

      # verify that we have the expected data
      path = j[:liked_users_albums_path]
      path.should_not == nil
      albums = zz_api_get path, 200
      albums.count.should == 2
      t2a1 = nil
      albums.each do |album|
        album.recursively_symbolize_keys!
        name = album[:name]
        ['t2-a1', 't2-a2'].include?(name).should == true
        t2a1 = album if name == 't2-a1'
      end

      t2a1.should_not == nil

      # and fetch the list of photos in an album
      photos = zz_api_get zz_api_photos_path(t2a1[:id]) + "?ver=#{t2a1[:cache_version]}", 200
      photos.length.should == t2a1[:photos_count]

      # now see if we can get invited users
      path = j[:invited_albums_path]
      path.should_not == nil
      albums = zz_api_get path, 200
    end

    it "should fetch albums as a guest" do
      # sign out
      zz_api_post zz_api_logout_path, nil, 200

      j = zz_api_get zz_api_albums_path(@user_id), 200
      #puts JSON.pretty_generate(j)
      j[:public].should == true
      j[:logged_in_user_id].should == nil
    end

    describe "create" do
      it "should create a new album" do
        params = {
            :name => "Freddy Frump's Album",
            :privacy => "hidden",
            :who_can_upload => "contributors",
            :who_can_download => 'viewers',
            :who_can_buy => 'contributors',
            :stream_to_twitter => true,
            :stream_to_facebook => false,
        }
        j = zz_api_post zz_api_create_album_path, params, 200, false
        zz_verify_all_fields_match(j, params)
        db_check = Album.find( j[:id] )
        db_check.id.should == j[:id]
        # now fetch it via the api
        album = zz_api_get zz_api_album_info_path(j[:id])
        album[:id].should == j[:id]
        params[:stream_to_twitter].should == album[:stream_to_twitter]

        # should fail to create again since same name
        j = zz_api_post zz_api_create_album_path, params, 409, false
      end

      it "should fail validation" do
        params = {
            :name => "Freddy Frump's Album",
            :privacy => "hidden",
            :who_can_upload => "bad value",
        }
        j = zz_api_post zz_api_create_album_path, params, 409, false
      end

      it "should delete an album" do
        params = {
            :name => "Freddy Frump's Album",
            :privacy => "hidden",
            :who_can_upload => "contributors",
            :who_can_download => 'viewers',
            :who_can_buy => 'contributors',
            :stream_to_twitter => true,
            :stream_to_facebook => false,
        }
        j = zz_api_post zz_api_create_album_path, params, 200, false
        j = zz_api_post zz_api_destroy_album_path(j[:id]), nil, 200
        db_check = Album.find_by_id(j[:id])
        db_check.should == nil
      end
    end

    describe "batch" do
      it "should get an error closing a batch with a bad album" do
        j = zz_api_post zz_api_close_batch_path(-99), nil, 404
      end

      it "should close an open batch" do
        album = Factory.create(:album, :user => @user, :name => "Batch Test")

        # no use the create_photos api to create a couple of photos and open the batch
        agent_id = "agent-#{rand(99999999999)}"
        # build up a couple of photos to create
        now = Time.now.to_i
        photos = []
        wanted_photo_count = 2
        wanted_photo_count.times do |i|
          photo = {
              :source_guid => "guid:#{i}-#{agent_id}",
              :caption => "#{i}-something",
              :size => 99999,
              :capture_date => now,
              :file_create_date => now,
              :source => "rpsec test",
              :rotate_to => 90,
              :crop_to => nil
          }
          photos << photo
        end

        ret_photos = zz_api_post zz_api_create_photos_path(album.id), { :agent_id => agent_id, :photos => photos }, 200, false
        ret_photos.length.should == wanted_photo_count

        # fetch the batch created above
        batch = UploadBatch.get_current_and_touch(@user_id, album.id, false)

        # now close it
        j = zz_api_post zz_api_close_batch_path(album.id), nil, 200

        batch.reload
        # now verify that it moved to finished
        batch.state.should == 'closed'
      end
    end


    describe "update" do
      before(:each) do
        @album = Factory.create(:album, :user => @user, :name => "Some Test Name")
      end

      it "should update album name with new name" do
        @album.name.should == "Some Test Name"
        j = zz_api_post zz_api_update_album_path(@album),  { :name => "New Name" }, 200, false
        j[:name].should == "New Name"
        @albumcheck = Album.find( @album.id )
        @albumcheck.name.should == "New Name"
      end

      it "should NOT update album name with blank name" do
        @album.name.should == "Some Test Name"
        j = zz_api_post zz_api_update_album_path(@album),  {  :name => "" }, 409, false
        j[:message].should include "cannot be blank"
        @album.name.should == "Some Test Name"
      end

      it "should NOT update album name with symbols only (FriendlyId:BlankError) name" do
        @album.name.should == "Some Test Name"
        j = zz_api_post zz_api_update_album_path(@album),  {  :name => "--//--//@@" }, 409, false
        j[:message].should include "at least 1 letter or number"
        @album.name.should == "Some Test Name"
      end

      it "should NOT update album name with existing album name" do
        @album.name.should == "Some Test Name"
        @album2 = Factory.create(:album, :user => @user, :name => "Second Album")
        @album2.name.should == "Second Album"
        j = zz_api_post zz_api_update_album_path(@album),  {  :name => "Second Album" }, 409, false
        j[:message].should include "already have"
        @album.name.should == "Some Test Name"
      end
    end

    describe "album share acl" do
      before(:each) do
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []
        @album = Factory.create(:album, :user => @user, :name => "ACL Test")
      end

      # verify expected count and then extract the group and emails from shared album acl result list
      # returns a hash of the group_id and one of the email to info object
      # returns as
      # found_group_ids, found_emails
      def extract_group_ids_and_emails(members)
        found_emails = {}
        members.each do |info|
          user = info[:user]
          if user
            email = user[:email]
            found_emails[email] = info if email
          end
        end
        found_group_ids = {}
        members.each do |info|
          found_group_ids[info[:id]] = info
        end

        [found_group_ids, found_emails]
      end

      # see if we match expected emails and group ids
      def match_expected_groups_and_emails(members, expected_ids, expected_emails, expected_permission)
        found_group_ids, found_emails = extract_group_ids_and_emails(members)
        expected_ids.each do |group_id|
          info = found_group_ids[group_id]
          info.should_not == nil
          info[:permission].should == expected_permission
        end
        expected_emails.each do |email|
          info = found_emails[email]
          info.should_not == nil
          info[:permission].should == expected_permission
        end
        [found_group_ids, found_emails]
      end

      it "should have one member when new" do
        j = zz_api_get zz_api_sharing_edit_album_path(@album), 200
        j[:members].length.should == 1

        j = zz_api_get zz_api_sharing_members_album_path(@album), 200
        j.length.should == 1
      end

      it "should fail with bad groups and emails" do
        members = {
            :emails => ['bad2@@@email.com'],
            :group_ids => [999999999999],
            :message => 'viewers welcome',
            :permission => AlbumACL::VIEWER_ROLE.name
        }
        j = zz_api_post zz_api_add_sharing_members_album_path(@album), members, ZZAPIError::INVALID_LIST_ARGS
        error = j[:message]
        error[:group_ids].length.should == 1
        error[:emails].length.should == 1
      end

      def match_delivered_email(email)
        ActionMailer::Base.deliveries.should satisfy do |messages|
          messages.index { |message| message.to == [email] }
        end
      end

      it "should add, delete, and update members and verify their role" do
        resque_jobs(resque_filter) do
          u1 = Factory.create(:user)
          u2 = Factory.create(:user)
          u3 = Factory.create(:user)
          email_user = 'email_user1@bitbucket.zangzing.com'
          members = {
              :emails => [email_user],
              :group_ids => [u1.my_group_id],
              :message => 'viewers welcome',
              :permission => AlbumACL::VIEWER_ROLE.name
          }
          expected_emails = [email_user]
          expected_ids = [u1.my_group_id]
          j = zz_api_post zz_api_add_sharing_members_album_path(@album), members, 200
          j.length.should == 3
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::VIEWER_ROLE.name)
          ActionMailer::Base.deliveries.length.should == 2
          match_delivered_email(email_user)
          match_delivered_email(u1.email)
          ActionMailer::Base.deliveries = []

          # add them again as viewers, should cause no emails
          j = zz_api_post zz_api_add_sharing_members_album_path(@album), members, 200
          j.length.should == 3
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::VIEWER_ROLE.name)
          ActionMailer::Base.deliveries.length.should == 0

          # now as contribs
          members[:permission] = AlbumACL::CONTRIBUTOR_ROLE.name
          j = zz_api_post zz_api_add_sharing_members_album_path(@album), members, 200
          j.length.should == 3
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::CONTRIBUTOR_ROLE.name)
          ActionMailer::Base.deliveries.length.should == 2
          match_delivered_email(email_user)
          match_delivered_email(u1.email)
          ActionMailer::Base.deliveries = []

          # again as contribs
          j = zz_api_post zz_api_add_sharing_members_album_path(@album), members, 200
          j.length.should == 3
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::CONTRIBUTOR_ROLE.name)
          ActionMailer::Base.deliveries.length.should == 0

          # now back to viewers
          members[:permission] = AlbumACL::VIEWER_ROLE.name
          j = zz_api_post zz_api_add_sharing_members_album_path(@album), members, 200
          j.length.should == 3
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::VIEWER_ROLE.name)
          ActionMailer::Base.deliveries.length.should == 2
          match_delivered_email(email_user)
          match_delivered_email(u1.email)
          ActionMailer::Base.deliveries = []

          # now add a group with new members
          group = Factory.create(:group, :user => @user)
          gm1 = Factory.create(:group_member, :group => group)
          gm2 = Factory.create(:group_member, :group => group)
          gm3 = Factory.create(:group_member, :group => group)
          members = {
              :emails => [],
              :group_ids => [group.id],
              :message => 'contributors welcome',
              :permission => AlbumACL::CONTRIBUTOR_ROLE.name
          }
          j = zz_api_post zz_api_add_sharing_members_album_path(@album), members, 200
          j.length.should == 4
          expected_emails = [email_user]
          expected_ids = [u1.my_group_id]
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::VIEWER_ROLE.name)
          expected_emails = []
          expected_ids = [group.id]
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::CONTRIBUTOR_ROLE.name)
          ActionMailer::Base.deliveries.length.should == 3
          match_delivered_email(gm1.user.email)
          match_delivered_email(gm2.user.email)
          match_delivered_email(gm3.user.email)
          ActionMailer::Base.deliveries = []

          # now remove the group
          member = {
              :member => {
                  :id => group.id,
              }
          }
          j = zz_api_post zz_api_delete_sharing_member_album_path(@album), member, 200
          j.length.should == 3
          expected_emails = [email_user]
          expected_ids = [u1.my_group_id]
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::VIEWER_ROLE.name)

          members = {
              :emails => [],
              :group_ids => [u2.my_group_id, u3.my_group_id],
              :message => 'contributors welcome',
              :permission => AlbumACL::CONTRIBUTOR_ROLE.name
          }
          expected_emails = [email_user]
          expected_ids = [u1.my_group_id]
          j = zz_api_post zz_api_add_sharing_members_album_path(@album), members, 200
          j.length.should == 5
          # first verify that viewers haven't changed
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::VIEWER_ROLE.name)

          # now see if we got the expected contribs
          expected_emails = []
          expected_ids = [u2.my_group_id, u3.my_group_id]
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::CONTRIBUTOR_ROLE.name)

          # now upgrade one of the viewers
          member = {
              :member => {
                  :id => u1.my_group_id,
                  :permission => AlbumACL::CONTRIBUTOR_ROLE.name
              }
          }
          j = zz_api_post zz_api_update_sharing_member_album_path(@album), member, 200
          j.length.should == 5
          expected_emails = [email_user]
          expected_ids = []
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::VIEWER_ROLE.name)
          expected_emails = []
          expected_ids = [u1.my_group_id, u2.my_group_id, u3.my_group_id]
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::CONTRIBUTOR_ROLE.name)

          # now delete one of the contribs
          member = {
              :member => {
                  :id => u1.my_group_id,
              }
          }
          j = zz_api_post zz_api_delete_sharing_member_album_path(@album), member, 200
          j.length.should == 4
          # this time verify with sharing members call
          j = zz_api_get zz_api_sharing_members_album_path(@album), 200
          j.length.should == 4
          expected_emails = [email_user]
          expected_ids = []
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::VIEWER_ROLE.name)
          expected_emails = []
          expected_ids = [u2.my_group_id, u3.my_group_id]
          match_expected_groups_and_emails(j, expected_ids, expected_emails, AlbumACL::CONTRIBUTOR_ROLE.name)
        end
      end


    end

    describe "cache and acl" do
      before(:each) do
        @password = 'testtest'
        @u1 = Factory.create(:user, :password => @password)
        @u2 = Factory.create(:user, :password => @password)
        @u3 = Factory.create(:user, :password => @password)
        @u4 = Factory.create(:user, :password => @password)
        @u5 = Factory.create(:user, :password => @password)

        @g1u1 = Factory.create(:group, :user => @u1)
        Factory.create(:group_member, :group => @g1u1, :user => @u3)
        Factory.create(:group_member, :group => @g1u1, :user => @u4)
        @g2u1 = Factory.create(:group, :user => @u1)
        Factory.create(:group_member, :group => @g2u1, :user => @u3)
        Factory.create(:group_member, :group => @g2u1, :user => @u4)
        Factory.create(:group_member, :group => @g2u1, :user => @u5)

        @g1u2 = Factory.create(:group, :user => @u2)
        Factory.create(:group_member, :group => @g1u2, :user => @u3)
        Factory.create(:group_member, :group => @g1u2, :user => @u4)
        @g2u2 = Factory.create(:group, :user => @u2)
        Factory.create(:group_member, :group => @g2u2, :user => @u4)

        @a1u1 = Factory.create(:album, :privacy => Album::PASSWORD, :user => @u1, :name => "User 1 Cache Test 1")
        @a2u1 = Factory.create(:album, :privacy => Album::PASSWORD, :user => @u1, :name => "User 1 Cache Test 2")

        @a1u2 = Factory.create(:album, :privacy => Album::PASSWORD, :user => @u2, :name => "User 2 Cache Test 1")
        @a2u2 = Factory.create(:album, :privacy => Album::PASSWORD, :user => @u2, :name => "User 2 Cache Test 2")
      end

      def find_album_by_id(albums, id)
        albums.each do |album|
          return album if album[:id] == id
        end
        nil
      end

      it "should add groups to acl and verify they see albums" do
        @a1u1.add_contributors([@g1u1.id])
        @a1u1.add_viewers([@g2u1.id])

        zz_login(@u2.username, @password)
        j = zz_api_get zz_api_albums_path(@u2.id), 200
        path = j[:invited_albums_path]
        albums = zz_api_get path, 200
        albums.length.should == 0   #  not in any of the groups added so should get nothing

        zz_login(@u3.username, @password)
        j = zz_api_get zz_api_albums_path(@u3.id), 200
        path = j[:invited_albums_path]
        albums = zz_api_get path, 200
        albums.length.should == 1
        albums[0][:id].should == @a1u1.id
        albums[0][:my_role].should == AlbumACL::CONTRIBUTOR_ROLE.name

        # now add user 2 and see if he can see it
        GroupMember.update_members([[@g2u1.id, @u2.id]])  # do the low level member change to get cache invalidate
        zz_login(@u2.username, @password)
        j = zz_api_get zz_api_albums_path(@u2.id), 200
        path = j[:invited_albums_path]
        albums = zz_api_get path, 200
        albums.length.should == 1
        albums[0][:id].should == @a1u1.id
        albums[0][:my_role].should == AlbumACL::VIEWER_ROLE.name

        # add group to a second album
        @a2u1.add_contributors([@g2u1.id])
        j = zz_api_get zz_api_albums_path(@u2.id), 200
        path = j[:invited_albums_path]
        albums = zz_api_get path, 200
        albums.length.should == 2
        a1 = find_album_by_id(albums, @a1u1.id)
        a1.should_not == nil
        a1[:my_role].should == AlbumACL::VIEWER_ROLE.name
        a2 = find_album_by_id(albums, @a2u1.id)
        a2.should_not == nil
        a2[:my_role].should == AlbumACL::CONTRIBUTOR_ROLE.name

        # now downgrade group 1, which had Contrib rights to viewer
        @a1u1.add_viewers([@g1u1.id])

        # user 3 should now only be a viewer on a1
        zz_login(@u3.username, @password)
        j = zz_api_get zz_api_albums_path(@u3.id), 200
        path = j[:invited_albums_path]
        albums = zz_api_get path, 200
        albums.length.should == 2
        a1 = find_album_by_id(albums, @a1u1.id)
        a1.should_not == nil
        a1[:my_role].should == AlbumACL::VIEWER_ROLE.name
        a2 = find_album_by_id(albums, @a2u1.id)
        a2.should_not == nil
        a2[:my_role].should == AlbumACL::CONTRIBUTOR_ROLE.name

        # now delete group 2
        @g2u1.destroy

        # user 3 should have one invited albums
        zz_login(@u3.username, @password)
        j = zz_api_get zz_api_albums_path(@u3.id), 200
        path = j[:invited_albums_path]
        albums = zz_api_get path, 200
        albums.length.should == 1
        a1 = find_album_by_id(albums, @a1u1.id)
        a1.should_not == nil
        a1[:my_role].should == AlbumACL::VIEWER_ROLE.name
        a2 = find_album_by_id(albums, @a2u1.id)
        a2.should == nil

        # user 2 should have no albums
        zz_login(@u2.username, @password)
        j = zz_api_get zz_api_albums_path(@u2.id), 200
        path = j[:invited_albums_path]
        albums = zz_api_get path, 200
        albums.length.should == 0
      end

      it "should add user to groups to acl and detect album changes" do
        @a1u1.add_contributors([@g1u1.id])
        @a2u1.add_viewers([@g2u1.id])
        @a1u2.add_viewers([@g1u2.id])
        @a2u2.add_contributors([@g2u2.id])

        zz_login(@u4.username, @password)
        j = zz_api_get zz_api_albums_path(@u4.id), 200
        path = j[:invited_albums_path]
        albums = zz_api_get path, 200
        albums.length.should == 4
        a1 = find_album_by_id(albums, @a1u1.id)
        a1.should_not == nil
        a1[:my_role].should == AlbumACL::CONTRIBUTOR_ROLE.name
        a2 = find_album_by_id(albums, @a2u1.id)
        a2.should_not == nil
        a2[:my_role].should == AlbumACL::VIEWER_ROLE.name
        a1 = find_album_by_id(albums, @a1u2.id)
        a1.should_not == nil
        a1[:my_role].should == AlbumACL::VIEWER_ROLE.name
        a2 = find_album_by_id(albums, @a2u2.id)
        a2.should_not == nil
        a2[:my_role].should == AlbumACL::CONTRIBUTOR_ROLE.name

        # now update the name of album 1
        new_album_name = "Album Name Changed 1"
        @a1u1.name = new_album_name
        @a1u1.save!
        j = zz_api_get zz_api_albums_path(@u4.id), 200
        path = j[:invited_albums_path]
        albums = zz_api_get path, 200
        albums.length.should == 4
        a1 = find_album_by_id(albums, @a1u1.id)
        a1.should_not == nil
        a1[:my_role].should == AlbumACL::CONTRIBUTOR_ROLE.name
        a1[:name].should == new_album_name
      end
    end
  end
end