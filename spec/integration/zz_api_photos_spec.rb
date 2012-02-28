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

    describe "sort photos" do

      def verify_order(photos, ordered_ids)
        photos.length.should == ordered_ids.length
        len = photos.length
        cur = 0
        while cur < len do
          photos[cur][:id].should == ordered_ids[cur]
          cur += 1
        end
      end

      it "should sort photos" do
        album = Factory.create(:album, :user => @user)
        photos = []
        photos << Factory.create(:photo, :user => @user, :album => album, :caption => "C", :capture_date => Time.at(10))
        photos << Factory.create(:photo, :user => @user, :album => album, :caption => "B", :capture_date => Time.at(11))
        photos << Factory.create(:photo, :user => @user, :album => album, :caption => "A", :capture_date => Time.at(12))
        photos << Factory.create(:photo, :user => @user, :album => album, :caption => "c", :capture_date => Time.at(13))
        photos << Factory.create(:photo, :user => @user, :album => album, :caption => "D", :capture_date => Time.at(14))
        photos << Factory.create(:photo, :user => @user, :album => album, :caption => '', :capture_date => Time.at(15))
        photos << Factory.create(:photo, :user => @user, :album => album, :caption => nil, :capture_date => Time.at(9))
        order_by_name_asc = [
            photos[6].id,
            photos[5].id,
            photos[2].id,
            photos[1].id,
            photos[0].id,
            photos[3].id,
            photos[4].id,
        ]
        order_by_name_desc = order_by_name_asc.reverse
        order_by_date_asc = [
            photos[6].id,
            photos[0].id,
            photos[1].id,
            photos[2].id,
            photos[3].id,
            photos[4].id,
            photos[5].id,
        ]
        order_by_date_desc = order_by_date_asc.reverse

        ret_photos = zz_api_get zz_api_photos_path(album.id), 200, false, {:sort => 'name-asc'}
        verify_order(ret_photos, order_by_name_asc)

        ret_photos = zz_api_get zz_api_photos_path(album.id), 200, false, {:sort => 'name-desc'}
        verify_order(ret_photos, order_by_name_desc)

        ret_photos = zz_api_get zz_api_photos_path(album.id), 200, false, {:sort => 'date-asc'}
        verify_order(ret_photos, order_by_date_asc)

        ret_photos = zz_api_get zz_api_photos_path(album.id), 200, false, {:sort => 'date-desc'}
        verify_order(ret_photos, order_by_date_desc)
      end
    end

  end
end
