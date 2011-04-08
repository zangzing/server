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
        MIN_TIME_BETWEEN_BATCH_CLOSE =  59  # make sure runs are at least this far apart
                                            # possible to have multiple items waiting if scheduler
                                            # was left running while we were stopped
        MIN_TIME_BETWEEN_BATCH_FINAL =  700
        MIN_TIME_BETWEEN_CACHE_TRIM =   600

        @queue = :io_bound

        def self.batch_close_ok?
          @@batch_close ||= MinRunTracker.new(MIN_TIME_BETWEEN_BATCH_CLOSE)
          @@batch_close.should_run?
        end

        def self.batch_final_ok?
          @@batch_final ||= MinRunTracker.new(MIN_TIME_BETWEEN_BATCH_FINAL)
          @@batch_final.should_run?
        end

        def self.cache_trim_ok?
          @@cache_trim ||= MinRunTracker.new(MIN_TIME_BETWEEN_CACHE_TRIM)
          @@cache_trim.should_run?
        end


        # run a sweep
        def self.perform()
          start_time = Time.now.to_f
          if batch_close_ok?
            UploadBatch.close_pending_batches
          end
          if batch_final_ok?
            UploadBatch.finalize_stale_batches
          end
          if cache_trim_ok?
            # trim the album cache
            Cache::Album::Manager.shared.trim_tracker
          end
          end_time = Time.now.to_f
          msec = "%0.2f" % ((end_time - start_time) * 1000)
          msg = "#{Time.now} - Task sweeper took: #{msec}ms"
          Rails.logger.info(msg)
        end
    end

  end
end

