module Delayed
  module Backend
    module ActiveRecord

      class CpuBoundJob < Job
        set_table_name :cpu_bound_jobs

        # Find a few candidate jobs to run (in case some immediately get locked by others).
        def self.find_available(worker_name, limit = 5, max_run_time = CpuBoundWorker.max_run_time)
          scope = self.ready_to_run(worker_name, max_run_time)
          scope = scope.scoped(:conditions => ['priority >= ?', CpuBoundWorker.min_priority]) if CpuBoundWorker.min_priority
          scope = scope.scoped(:conditions => ['priority <= ?', CpuBoundWorker.max_priority]) if CpuBoundWorker.max_priority

          ::ActiveRecord::Base.silence do
            scope.by_priority.all(:limit => limit)
          end
        end
      end


    end
  end
end
