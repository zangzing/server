require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

describe "ZZ API Identities" do

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

    it "should set and verify facebook identity" do
      j = zz_api_post zz_api_update_identity_path, {:service => 'facebook', :credentials => 'AAACCaqxPOLwBADP5JnsKEivSZAI0s1IqZBRBuDFyqNWZAjvFwd1TqZBU9cGb0D5SeNYgGvk0aqDfd3O78ZA4RSm0TZCKdV6YSLgPH6Er098AZDZD'}, 200, true
      j[:credentials_valid].should == true

      # verify reflected in user info
      j = zz_api_get zz_api_current_user_info_path, 200
      j[:has_facebook_token].should == true

      # now clear the token
      j = zz_api_post zz_api_update_identity_path, {:service => 'facebook', :credentials => nil}, 200, true
      j[:credentials_valid].should == false

      # and verify that nil got saved
      j = zz_api_get zz_api_current_user_info_path, 200
      j[:has_facebook_token].should == false

      # and try with a bad token
      j = zz_api_post zz_api_update_identity_path, {:service => 'facebook', :credentials => 'badtoken'}, 200, true
      j[:credentials_valid].should == false
    end

    it "should set and verify twitter identity" do
      j = zz_api_post zz_api_update_identity_path, {:service => 'twitter', :credentials => '511107988-5klSnrfvDMw6phU1zJXe1EDb8hoFkBwjWpTYEG0P_NtkOqZzGloYM9asFiCx9UA98vKDhGM7l4qUeTBvCUjo'}, 200, true
      j[:credentials_valid].should == true

      # verify reflected in user info
      j = zz_api_get zz_api_current_user_info_path, 200
      j[:has_twitter_token].should == true

      # now clear the token
      j = zz_api_post zz_api_update_identity_path, {:service => 'twitter', :credentials => nil}, 200, true
      j[:credentials_valid].should == false

      # and verify that nil got saved
      j = zz_api_get zz_api_current_user_info_path, 200
      j[:has_twitter_token].should == false

      j = zz_api_post zz_api_update_identity_path, {:service => 'twitter', :credentials => 'bad_token'}, 200, true
      j[:credentials_valid].should == false
    end

    it "should validate multiple credentials" do
      services = {
          :services => [:twitter, :facebook]
      }
      j = zz_api_post zz_api_validate_credentials_identity_path, services, 200
      j.length.should == services[:services].length
      j[:twitter][:credentials_valid].should == false
      j[:twitter][:has_credentials].should == false
      j[:facebook][:credentials_valid].should == false
      j[:facebook][:has_credentials].should == false

      # now set valid creds
      j = zz_api_post zz_api_update_identity_path, {:service => :facebook, :credentials => 'AAACCaqxPOLwBADP5JnsKEivSZAI0s1IqZBRBuDFyqNWZAjvFwd1TqZBU9cGb0D5SeNYgGvk0aqDfd3O78ZA4RSm0TZCKdV6YSLgPH6Er098AZDZD'}, 200, true
      j[:credentials_valid].should == true
      j = zz_api_post zz_api_update_identity_path, {:service => :twitter, :credentials => '511107988-5klSnrfvDMw6phU1zJXe1EDb8hoFkBwjWpTYEG0P_NtkOqZzGloYM9asFiCx9UA98vKDhGM7l4qUeTBvCUjo'}, 200, true
      j[:credentials_valid].should == true

      j = zz_api_post zz_api_validate_credentials_identity_path, services, 200
      j.length.should == services[:services].length
      j[:twitter][:credentials_valid].should == true
      j[:twitter][:has_credentials].should == true
      j[:facebook][:credentials_valid].should == true
      j[:facebook][:has_credentials].should == true
    end

    it "should fail with invalid service name" do
      services = {
          :services => [:badtwitter, :facebook]
      }
      j = zz_api_post zz_api_validate_credentials_identity_path, services, 409
      j[:message].should == 'The service name is not valid'
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

# Test account for twitter
# username: momentrspectest
# pw: see keychain (standard common password)
# dev/test token: 511107988-5klSnrfvDMw6phU1zJXe1EDb8hoFkBwjWpTYEG0P_NtkOqZzGloYM9asFiCx9UA98vKDhGM7l4qUeTBvCUjo
#
