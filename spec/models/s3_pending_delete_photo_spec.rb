require 'spec_helper'

describe S3PendingDeletePhoto do

  it "should create test entries and verify sweeper deletion" do
    # don't run any resque jobs
    resque_jobs(:only => []) do
      test_count = 10 # make sure even number
      test_count_half = test_count / 2
      job_age = 30.days.ago
      test_count.times do
        S3PendingDeletePhoto.create(:photo_id => 1, :user_id => 1, :album_id => 1, :guid_part => 'a', :prefix => 'a', :image_bucket => 'a', :encoded_sizes => 'olmts', :caption => 'a', :deleted_at => job_age)
      end

      count = S3PendingDeletePhoto.where(:photo_id => 1, :user_id => 1, :album_id => 1).count
      count.should == test_count

      # now see if the sweeper deletes them (half at a time)
      S3PendingDeletePhoto.queue_deletes(job_age, test_count_half)
      count = S3PendingDeletePhoto.where(:photo_id => 1, :user_id => 1, :album_id => 1).count
      count.should == test_count_half

      S3PendingDeletePhoto.queue_deletes(job_age, test_count_half)
      count = S3PendingDeletePhoto.where(:photo_id => 1, :user_id => 1, :album_id => 1).count
      count.should == 0
    end
  end

end