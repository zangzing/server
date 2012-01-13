require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

describe "ZZ API Photos" do

  describe "photos" do
    before(:each) do
      @user_id = zz_login("test1", "testtest")
      @user = User.find(@user_id)
    end

    it "should create photos and verify pending" do
      album = Factory.create(:album, :user => @user)

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

      photo1 = ret_photos[0]
      photo1[:user_id].should == @user_id

      ret_photos[0][:id].should_not == ret_photos[1][:id]

      # now all pending to see if we have the same photo ids
      # returned to us
      expected_ids = ret_photos.map { |p| p[:id] }
      pend_photos = zz_api_get zz_api_pending_uploads_path(agent_id)

      pend_photos.length.should == wanted_photo_count
      pend_photos.each do |photo|
        expected_ids.include?(photo[:id]).should == true
      end
    end

  end
end
