require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

describe "Mobile API" do

  describe "credentials" do
    it "should fail to login" do
      body = mobile_body({:email => "test1", :password => "badpassword"})
      path = build_full_path(mobile_login_path, true)
      post path, body, mobile_headers
      j = JSON.parse(response.body).recursively_symbolize_keys!
      #puts JSON.pretty_generate(j)
      j[:code].should eql(401)
    end

    it "should login" do
      body = mobile_body({ :email => "test1", :password => "testtest" })
      path = build_full_path(mobile_login_path, true)
      post path, body, mobile_headers
      response.status.should eql(200)
      login_info = JSON.parse(response.body).recursively_symbolize_keys!
      uid = login_info[:user_id]
    end
  end

  describe "albums" do
    before(:each) do
      body = mobile_body({ :email => "test1", :password => "testtest" })
      path = build_full_path(mobile_login_path, true)
      post path, body, mobile_headers
      response.status.should eql(200)
      login_info = JSON.parse(response.body).recursively_symbolize_keys!
      @user_id = login_info[:user_id]
    end

    it "should fetch albums and verify liked_user_albums_path and invited_users_path" do
      path = build_full_path(mobile_albums_path(@user_id))
      get path, nil, mobile_headers
      response.status.should eql(200)
      j = JSON.parse(response.body).recursively_symbolize_keys!
      #puts JSON.pretty_generate(j)
      j[:public].should == false
      j[:logged_in_user_id].should == @user_id

      # verify that we have the expected data
      path = j[:liked_users_albums_path]
      path.should_not == nil
      get path, nil, mobile_headers
      response.status.should eql(200)
      albums = JSON.parse(response.body)
      #puts JSON.pretty_generate(albums)
      albums.count.should == 2
      albums.each do |album|
        album.recursively_symbolize_keys!
        name = album[:name]
       ['t2-a1', 't2-a2'].include?(name).should == true
      end

      # now see if we can get invited users
      path = j[:invited_albums_path]
      path.should_not == nil
      get path, nil, mobile_headers
      response.status.should eql(200)
      albums = JSON.parse(response.body)
    end

    it "should fetch albums as a guest" do
      # sign out
      path = build_full_path(mobile_logout_path)
      post path, nil, mobile_headers
      response.status.should eql(200)

      path = build_full_path(mobile_albums_path(@user_id))
      get path, nil, mobile_headers
      response.status.should eql(200)
      body = response.body
      j = JSON.parse(body).recursively_symbolize_keys!
      #puts JSON.pretty_generate(j)
      j[:public].should == true
      j[:logged_in_user_id].should == nil
    end

    it "should fail to get user info" do
      path = build_full_path(mobile_user_info_path(99999999))
      get path, nil, mobile_headers
      response.status.should eql(509)
      body = response.body
      j = JSON.parse(body).recursively_symbolize_keys!
      #puts JSON.pretty_generate(j)
      j[:message].should == "Couldn't find User with ID=99999999"
    end

    it "should get user info" do
      path = build_full_path(mobile_user_info_path(@user_id))
      get path, nil, mobile_headers
      response.status.should eql(200)
      body = response.body
      j = JSON.parse(body).recursively_symbolize_keys!
      #puts JSON.pretty_generate(j)
      j[:username].should == 'test1'
    end
  end
end