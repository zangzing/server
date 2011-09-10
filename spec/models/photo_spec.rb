require 'spec_helper'

describe Photo do

  it "should create and delete photo dependencies" do
    resque_loopback(:only => []) do
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
    # but just including to show its usage
    resque_loopback(:except => [ZZ::Async::MailingListSync]) do
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