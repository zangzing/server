require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

resque_filter = {:except => [ZZ::Async::MailingListSync]}

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

    it "should verify system rights" do
      username = 'test1'
      zz_logout
      j = zz_api_post zz_api_create_or_login_path, {:email => username, :password => 'testtest'}, 200, true
      j[:role].should == SystemRightsACL::USER_ROLE.name

      role_names = SystemRightsACL.role_names
      index = 0
      j[:available_roles].each do |name|
        name.should == role_names[index]
        index += 1
      end

      username = 'test2'
      SystemRightsACL.set_role(username, SystemRightsACL::SUPER_MODERATOR_ROLE.name)
      zz_logout
      j = zz_api_post zz_api_create_or_login_path, {:email => username, :password => 'testtest'}, 200, true
      j[:role].should == SystemRightsACL::SUPER_MODERATOR_ROLE.name

      SystemRightsACL.set_role(username, SystemRightsACL::USER_ROLE.name)
      zz_logout
      j = zz_api_post zz_api_create_or_login_path, {:email => username, :password => 'testtest'}, 200, true
      j[:role].should == SystemRightsACL::USER_ROLE.name
    end

    it "should fail to get user info" do
      j = zz_api_get zz_api_user_info_path(99999999), 509
      j[:message].should == "Couldn't find User with ID=99999999"
    end

    it "should get user info" do
      j = zz_api_get zz_api_user_info_path(@user_id), 200
      j[:username].should == 'test1'
    end

    it "should get current user info" do
      j = zz_api_get zz_api_current_user_info_path, 200
      j[:username].should == 'test1'
    end

    it "should check availability of username" do
      j = zz_api_post zz_api_available_user_path, {:username => 'shouldnotexist', :email => nil}, 200
      j[:username_available].should == true
      j[:email_available].should == true

      j = zz_api_post zz_api_available_user_path, {:username => 'shouldnotexist'}, 200
      j[:username_available].should == true
      j[:email_available].should == true

      j = zz_api_post zz_api_available_user_path, {:username => @user.username, :email => @user.email}, 200
      j[:username_available].should == true   # case where we are same user
      j[:email_available].should == true

      zz_logout
      j = zz_api_post zz_api_available_user_path, {:username => @user.username, :email => @user.email}, 200
      j[:username_available].should == false
      j[:email_available].should == false
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
      email_only = "Joe_Some_User99@Usertest.com"
      emails = ["Joe #{last_name} <#{email_only}>"]

      j = zz_api_post zz_api_find_or_create_user_path, {:user_ids => ids, :create => true, :emails => emails, :user_names => names}, 200
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
      # also, upcase one of the emails to verify case insensitive match
      emails = [user1.email, user2.email, email_only.upcase]
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

    it "should find and not create users" do
      user1 = Factory.create(:user)
      dont_find_user = 'neverfindthisuser'
      names = [user1.username, dont_find_user]
      user2 = Factory.create(:user)
      dont_find_id = 99999999999999
      ids = [user2.id, dont_find_id]  # the bogus id should not cause failure but should end up in missing list
      last_name = "SomeUser_#{rand(99999)}"
      email_only = "joe_some_user99@usertest.com"
      dont_find_email = "Joe #{last_name} <#{email_only}>"
      emails = [dont_find_email]

      j = zz_api_post zz_api_find_or_create_user_path, {:user_ids => ids, :create => false, :emails => emails, :user_names => names}, 200
      members = j[:users]
      members.length.should == 2
      missing = j[:not_found]
      missing_ids = missing[:user_ids]
      missing_ids[0][:token].should == dont_find_id
      missing_ids[0][:index].should == 1
      missing_user_names = missing[:user_names]
      missing_user_names[0][:token].should == dont_find_user
      missing_user_names[0][:index].should == 1
      missing_emails = missing[:emails]
      missing_emails[0][:token].should == dont_find_email
      missing_emails[0][:index].should == 0

      is_matching_user?(names[0], :username, members).should == true
      is_matching_user?(ids[0], :id, members).should == true
      is_matching_user?(last_name, :last_name, members).should == false

    end

    describe "Two Phase Join" do

      it "should one step create new user" do
        zz_logout

        email = "single_phase_user@bitbucket.zangzing.com"
        password = "singlepass"
        username = "onephasetest"
        name = "One Phase"
        hash = {
            :email => email,
            :password => password,
            :name => name,
            :username => username,

            :create => true,
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:completed_step].should == nil
        j[:user][:username].should == username
        j[:user][:automatic].should == false
      end

      it "should create new user" do
        resque_jobs(:except => [ZZ::Async::MailingListSync]) do
          zz_logout

          email = "two_phase_user@bitbucket.zangzing.com"
          password = "twopass"
          hash = {
              :email => email,
              :password => password,
              :create => true,
          }
          j = zz_api_post zz_api_create_or_login_path, hash, 200, true
          j[:user][:completed_step].should == 1

          # now on to phase two
          username = "twophasetest"
          name = "Two Phase"
          hash = {
              :name => name,
              :username => username,
              :profile_photo_url => 'http://3.zz.s3.amazonaws.com/i/656930cc-340d-460b-9254-d4846bb43b5b-t?1303190538'
          }
          j = zz_api_post zz_api_login_create_finish_path, hash, 200, true
          j[:user][:username].should == username
          user_id = j[:user][:id]
          user = User.find(user_id)
          user.profile_album.id.should == j[:user][:profile_album_id]
          photo = user.profile_album.cover
          photo.ready?.should == true

          # verify that we can log in with newly created account
          zz_logout
          hash = {
              :email => email,
              :password => password,
          }
          j = zz_api_post zz_api_create_or_login_path, hash, 200, true
          j[:user][:automatic].should == false
        end
      end

      it "should convert automatic to new user" do
        zz_logout

        # do phase one twice to first create the
        # automatic user, and then independently
        # continue on with it in the already automatic state
        email = "two_phase_user@bitbucket.zangzing.com"
        password = "twopass"
        hash = {
            :email => email,
            :password => password,
            :create => true,
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:completed_step].should == 1

        # this should fail since we can't log in with a automatic user
        zz_logout
        hash[:create] = false
        j = zz_api_post zz_api_create_or_login_path, hash, 401, true

        # user already exists but should be able to continue
        # regardless since automatic
        zz_logout
        hash[:create] = true  # allowed to log in when already created if in create mode
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:completed_step].should == 1
        j[:user][:automatic].should == true

        # now on to phase two
        username = "twophasetest"
        name = "Two Phase"
        hash = {
            :name => name,
            :username => username,
        }
        j = zz_api_post zz_api_login_create_finish_path, hash, 200, true
        j[:user][:username].should == username

        # verify that we can log in with newly created account
        zz_logout
        hash = {
            :email => email,
            :password => password,
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:automatic].should == false
      end

      it "should not let you login when already logged in" do
        zz_logout

        email = "single_phase_user@bitbucket.zangzing.com"
        password = "singlepass"
        username = "onephasetest"
        name = "One Phase"
        hash = {
            :email => email,
            :password => password,
            :name => name,
            :username => username,

            :create => true,
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:completed_step].should == nil
        j[:user][:username].should == username
        j[:user][:automatic].should == false

        # this should fail since we can't log in when already logged in
        j = zz_api_post zz_api_create_or_login_path, hash, 401, true
      end

      it "should log you in with credentials" do
        zz_logout

        email = "test1@bitbucket.zangzing.com"
        password = "singlepass"
        username = "credentials1"
        credentials = "AAACCaqxPOLwBADP5JnsKEivSZAI0s1IqZBRBuDFyqNWZAjvFwd1TqZBU9cGb0D5SeNYgGvk0aqDfd3O78ZA4RSm0TZCKdV6YSLgPH6Er098AZDZD"
        name = "One Phase"
        hash = {
            :email => email,
            :password => password,
            :name => name,
            :username => username,
            :credentials => credentials,
            :service => 'facebook',
            :create => true,
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:completed_step].should == nil
        j[:user][:username].should == username
        j[:user][:automatic].should == false
        new_user_id = j[:user][:id]

        zz_logout
        hash = {
            :credentials => credentials,
            :service => 'facebook',
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:id].should == new_user_id
        j[:user][:completed_step].should == nil
        j[:user][:username].should == username
        j[:user][:automatic].should == false

        # now create another account
        zz_logout
        email2 = "test2@bitbucket.zangzing.com"
        password = "singlepass"
        username2 = "credentials2"
        credentials = "AAACCaqxPOLwBADP5JnsKEivSZAI0s1IqZBRBuDFyqNWZAjvFwd1TqZBU9cGb0D5SeNYgGvk0aqDfd3O78ZA4RSm0TZCKdV6YSLgPH6Er098AZDZD"
        name = "One Phase"
        hash = {
            :email => email2,
            :password => password,
            :name => name,
            :username => username2,
            :credentials => credentials,
            :service => 'facebook',
            :create => true,
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:username].should == username2
        j[:user][:automatic].should == false

        zz_logout
        # login with just credentials
        hash = {
            :credentials => credentials,
            :service => 'facebook',
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:username].should == username2

        # now switch to first users info which will re-associate credentials
        zz_logout
        hash = {
            :email => email,
            :password => password,
            :credentials => credentials,
            :service => 'facebook',
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:username].should == username

        # and verify that we get user 1 when we log in with credentials now
        zz_logout
        hash = {
            :credentials => credentials,
            :service => 'facebook',
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:username].should == username

        # finally verify that we can still log in user 2 without creds
        zz_logout
        hash = {
            :email => email2,
            :password => password,
        }
        j = zz_api_post zz_api_create_or_login_path, hash, 200, true
        j[:user][:username].should == username2

      end

      it "should create user from credentials" do
        resque_jobs(resque_filter) do
          zz_logout

          credentials = "AAACCaqxPOLwBADP5JnsKEivSZAI0s1IqZBRBuDFyqNWZAjvFwd1TqZBU9cGb0D5SeNYgGvk0aqDfd3O78ZA4RSm0TZCKdV6YSLgPH6Er098AZDZD"
          hash = {
              :credentials => credentials,
              :service => 'facebook',
              :create => true,
          }
          j = zz_api_post zz_api_create_or_login_path, hash, 200, true
          j[:user][:completed_step].should == nil
          j[:user][:first_name].should == "Test"
          j[:user][:last_name].should == "Moment"
          j[:user][:automatic].should == false
          new_user_id = j[:user][:id]

          profile_album_id = j[:user][:profile_album_id]
          profile_album = Album.find(profile_album_id)
          cover_photo = Factory.create(:full_photo, :album => profile_album)
          # test setting profile photo
          j = zz_api_post zz_api_update_album_path(profile_album_id),  { :cover_photo_id => cover_photo.id }, 200, false
          cover_url = j[:c_url]
          cover_url.should_not == nil

          # now make sure we can get info about ourselves
          j = zz_api_get zz_api_current_user_info_path, 200
          j[:id].should == new_user_id
          j[:profile_photo_url].should == cover_url

          # make sure we can log in now
          zz_logout
          hash = {
              :credentials => credentials,
              :service => 'facebook',
          }
          j = zz_api_post zz_api_create_or_login_path, hash, 200, true
          j[:user][:id].should == new_user_id

          # try to create again, should act just like a login
          zz_logout
          hash = {
              :credentials => credentials,
              :service => 'facebook',
              :create => true,
          }
          j = zz_api_post zz_api_create_or_login_path, hash, 200, true
          j[:user][:id].should == new_user_id

          # now clear the credential info from the identity
          user = User.find(new_user_id)
          identity = user.identity_for_facebook
          identity.service_user_id = nil
          identity.credentials = nil
          identity.save!

          # create, this time, should fail
          zz_logout
          hash = {
              :credentials => credentials,
              :service => 'facebook',
              :create => true,
          }
          j = zz_api_post zz_api_create_or_login_path, hash, 401, true
        end
      end

    end
end


# Test account info for facebook "Test Moment" created with:
# https://graph.facebook.com/143394669017276/accounts/test-users?installed=true&name=Test%20Moment&permissions=user_photos,user_photo_video_tags,friends_photo_video_tags,friends_photos,publish_stream,offline_access,read_friendlists,email&method=post&access_token=143394669017276|h14LUgaObyuoERoC0CFxgrWQNTs
#
#{
#   "id": "100003517493921",
#   "access_token": "AAACCaqxPOLwBADP5JnsKEivSZAI0s1IqZBRBuDFyqNWZAjvFwd1TqZBU9cGb0D5SeNYgGvk0aqDfd3O78ZA4RSm0TZCKdV6YSLgPH6Er098AZDZD",
#   "login_url": "https://www.facebook.com/platform/test_account_login.php?user_id=100003517493921&n=n89po72P9iXwQBp",
#   "email": "test_oqneasv_moment@tfbnw.net",
#   "password": "837280091"
#}