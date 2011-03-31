module ZZ
  module Async

    # This is a scheduler job run periodically
    # that we use to sweep the batch upload table
    # and make sure any stale jobs get closed out
    class BatchSweeper < Base
        MIN_TIME_BETWEEN_RUNS = 59  # make sure runs are at least this far apart
                                    # possible to have multiple items waiting if scheduler
                                    # was left running while we were stopped
        @queue = :io_bound

        def self.last_run
          @@last_run ||= 0
        end

        def self.should_run
          now = Time.now.to_i
          next_run_ok_at = last_run + MIN_TIME_BETWEEN_RUNS
          if (now >= next_run_ok_at)
            @@last_run = now
            return true
          end
          return false
        end

        # run a sweep
        def self.perform()
          if (should_run)
            #puts "Batch Sweeper run at " + Time.now().to_s
            UploadBatch.close_pending_batches
            UploadBatch.finalize_stale_batches
          end
        end
    end

  end
end

