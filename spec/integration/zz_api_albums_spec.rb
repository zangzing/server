require 'spec_helper'
require 'test_utils'

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
  end
end