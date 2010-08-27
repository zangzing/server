module Delayed
  module Backend
    module ActiveRecord

      class IoBoundJob < Job
        set_table_name :io_bound_jobs

        # Find a few candidate jobs to run (in case some immediately get locked by others).
        def self.find_available(worker_name, limit = 5, max_run_time = IoBoundWorker.max_run_time)
          scope = self.ready_to_run(worker_name, max_run_time)
          scope = scope.scoped(:conditions => ['priority >= ?', IoBoundWorker.min_priority]) if IoBoundWorker.min_priority
          scope = scope.scoped(:conditions => ['priority <= ?', IoBoundWorker.max_priority]) if IoBoundWorker.max_priority

          ::ActiveRecord::Base.silence do
            scope.by_priority.all(:limit => limit)
          end
        end

      end
    end
  end
end
