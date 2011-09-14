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

  it "should create a full photo and verify delete" do
    # perform this with resque in loopback so the complete operation takes place
    # note, we don't want subscribe emails so we filter out ZZ::Async::MailingListSync
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
      res.class.should == Net::HTTPNotFound

    end
  end
end