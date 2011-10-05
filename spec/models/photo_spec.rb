require 'spec_helper'

describe Photo do

  it "should create and delete photo dependencies" do
    # The default is no loopback but just showing this as
    # an example of the resque_loopback usage model.
    # If you don't want any resque jobs to trigger
    # you can simply leave this explicit call off.
    resque_jobs(:only => []) do
      photo = Factory.create(:photo)
      photo_id = photo.id
      photo_id.should_not == 0
      user = photo.user
      user.destroy
      photo = Photo.find_by_id(photo_id)
      photo.should == nil
    end
  end

  it "should create a full photo rotate and verify delete" do
    # perform this with resque in loopback so the complete operation takes place
    # note, we don't want subscribe emails so we filter out ZZ::Async::MailingListSync
    # trying to get the most bang for our buck with this single test since the
    # overhead of creating new full photo objects is relatively high
    resque_jobs(:except => [ZZ::Async::MailingListSync]) do
      photo = Factory.create(:full_photo)
      photo_id = photo.id
      photo_id.should_not == 0

      # reload to pick up the processed state
      photo.reload
      photo.ready?.should == true

      upload_batch = photo.upload_batch
      upload_batch.force_finish_no_notify
      upload_batch.state.should == "finished"

      # now apply an edit and verify response is ready
      response_id = photo.start_async_edit(:rotate_to => 90,
                                           :crop => { :top => '0.039', :left => 0.04, :bottom => 0.995, :right => 0.991 })
      photo_hash = JSON.parse(AsyncResponse.get_response(response_id))
      photo_hash['id'].should == photo_id

      # now make a copy in print mode
      options = {}
      crop = ImageCrop.new(0.2, 0, 1, 1)
      options[:crop] = crop
      options[:rotate_to] = 0
      options[:for_print] = true

      photo_copy = Photo.copy_photo(photo, options)
      photo_copy.reload
      photo_copy.ready?.should == true
      photo_copy.id.should_not == photo.id
      photo_copy.image_path.should_not == photo.image_path

      # now delete the photo
      photo.destroy
      # and verify that it was moved to pending deletes table
      pd = S3PendingDeletePhoto.find_by_photo_id(photo_id)
      pd.should_not == nil
      pd.photo_id.should == photo_id

      # now verify that the s3 link still exists
      url = pd.build_s3_url(AttachedImage::THUMB)
      res = Net::HTTP.get_response(URI.parse(url))
      res.class.should == Net::HTTPOK

      # now delete the pending delete object and verify s3 object is gone
      pd.destroy
      res = Net::HTTP.get_response(URI.parse(url))
      res.class.should_not == Net::HTTPOK

    end
  end
end