require 'cache/album/manager'

module ZZ
  module Async

    class MinRunTracker
      def initialize(min_time_between)
        @min_time_between = min_time_between
        @last_run = 0
      end

      def should_run?
        now = Time.now.to_i
        next_run_ok_at = @last_run + @min_time_between
        if (now >= next_run_ok_at)
          @last_run = now
          return true
        end
        return false
      end
    end

    # This is a scheduler job run periodically
    # that we use to sweep the batch upload table
    # and make sure any stale jobs get closed out
    class BatchSweeper < Base
        @queue = Priorities.queue_name('io', Priorities.batch_sweep)

        # for all of the _ok? calls below, we have
        # a minimum interval between runs to avoid
        # being flooded with incoming messages if
        # the scheduler has been running and we have
        # not been here to process them.  The times
        # specified below are in seconds.
        def self.batch_close_ok?
          @@batch_close ||= MinRunTracker.new(59)
          @@batch_close.should_run?
        end

        def self.batch_final_ok?
          @@batch_final ||= MinRunTracker.new(700)
          @@batch_final.should_run?
        end

        def self.cache_trim_ok?
          @@cache_trim ||= MinRunTracker.new(600)
          @@cache_trim.should_run?
        end

        def self.photo_delete_sweep_ok?
          @@photo_delete_sweep ||= MinRunTracker.new(59)
          @@photo_delete_sweep.should_run?
        end


        # just ensures an exception will not cause failure of the
        # next sweep operation
        def self.protected_run(should_run, &block)
          begin
            block.call() if should_run
          rescue Exception => ex
            raise ex
          end
        end

        # run a sweep
        def self.perform()
          start_time = Time.now.to_f
          protected_run(batch_close_ok?) do
            UploadBatch.close_pending_batches
          end
          protected_run(batch_final_ok?) do
            UploadBatch.finalize_stale_batches
          end
          protected_run(cache_trim_ok?) do
            # trim the album cache
            Cache::Album::Manager.shared.trim_tracker
          end
          protected_run(photo_delete_sweep_ok?) do
            # sweep the s3 photos that are ready to be permanently deleted
            S3PendingDeletePhoto.sweep_deletes
          end

          end_time = Time.now.to_f
          msec = "%0.2f" % ((end_time - start_time) * 1000)
          msg = "#{Time.now} - Task sweeper took: #{msec}ms"
          Rails.logger.info(msg)
        end
    end

  end
end

