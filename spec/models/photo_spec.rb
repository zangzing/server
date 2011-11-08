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

  it "should create a full photo, crop, rotate, and verify delete" do
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

      # verify dimensions and rotation
      photo.reload
      photo.rotated_width.should == photo.height
      photo.rotated_height.should == photo.width

      # now create hash and make sure height and width are there
      photo_hash = Photo.hash_one_photo(photo)
      photo_hash[:width].should == photo.width
      photo_hash[:height].should == photo.height

      # now make a copy in print mode
      options = {}
      crop = ImageCrop.new(0.2, 0, 1, 1)
      options[:crop] = crop
      options[:rotate_to] = 0
      options[:for_print] = true
      upload_batch = UploadBatch.get_current_and_touch(photo.user_id, photo.album_id)
      options[:upload_batch] = upload_batch

      originals = [{:photo => photo, :options => options}]
      photo_copies = Photo.copy_photos(originals)
      photo_copy = photo_copies[0]
      photo_copy.reload
      photo_copy.ready?.should == true
      photo_copy.id.should_not == photo.id
      photo_copy.image_path.should_not == photo.image_path
      photo_copy.destroy

      # now a benchmark to measure cost of copy prep on a set of photos
      Benchmark.bm(25) do |x|
        test_items = 10
        x.report("Copy #{test_items} photos") do
          1.times do
            originals = []
            test_items.times do
              originals << {:photo => photo, :options => options}
            end
            resque_jobs(:except => [ZZ::Async::MailingListSync, ZZ::Async::S3Upload]) do
              photo_copies = Photo.copy_photos(originals)
            end
          end
        end
      end

      # now delete the photo
      photo.destroy
      # and verify that it was moved to pending deletes table
      pd = S3PendingDeletePhoto.find_by_photo_id(photo_id)
      pd.should_not == nil
      pd.photo_id.should == photo_id

      # now verify that the s3 link still exists
      url = pd.build_s3_url(AttachedImage::IPHONE_GRID)
      res = Net::HTTP.get_response(URI.parse(url))
      res.class.should == Net::HTTPOK

      # now delete the pending delete object and verify s3 object is gone
      pd.destroy
      res = Net::HTTP.get_response(URI.parse(url))
      res.class.should_not == Net::HTTPOK

    end
  end

end