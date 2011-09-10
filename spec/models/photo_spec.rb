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

  it "should create a full photo" do
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
    end
  end
end