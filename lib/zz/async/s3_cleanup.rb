module ZZ
  module Async

    # remove S3 files
    class S3Cleanup < Base
        @queue = Priorities.io_queue_name(Priorities.cleanup)

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.enqueue(bucket, keys)
          super(bucket, keys)
        end

        # remove the specified images from s3 - includes resized variations as well
        def self.perform(bucket, keys)
          SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
            AttachedImage.remove_s3_photos(bucket, keys)
          end
        end
    end

  end
end