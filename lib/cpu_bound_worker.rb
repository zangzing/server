
module Delayed
  class CpuBoundWorker < Worker
    SLEEP = 5

    def initialize(options={})
      @quiet = options[:quiet]
      Delayed::CpuBoundJob.min_priority = options[:min_priority] if options.has_key?(:min_priority)
      Delayed::CpuBoundJob.max_priority = options[:max_priority] if options.has_key?(:max_priority)
    end

    def start
      say "*** Starting CpuBound job worker #{Delayed::CpuBoundJob.worker_name}"

      trap('TERM') { say 'Exiting...'; $exit = true }
      trap('INT')  { say 'Exiting...'; $exit = true }

      loop do
        result = nil

        realtime = Benchmark.realtime do
          result = Delayed::CpuBoundJob.work_off
        end

        count = result.sum

        break if $exit

        if count.zero?
          sleep(SLEEP)
        else
          say "#{count} CpuBound jobs processed at %.4f j/s, %d failed ..." % [count / realtime, result.last]
        end

        break if $exit
      end

    ensure
      Delayed::CpuBoundJob.clear_locks!
    end

  end
end
