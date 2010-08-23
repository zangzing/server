
module Delayed
  class IoBoundWorker < Worker
    SLEEP = 5

    def initialize(options={})
      @quiet = options[:quiet]
      Delayed::IoBoundJob.min_priority = options[:min_priority] if options.has_key?(:min_priority)
      Delayed::IoBoundJob.max_priority = options[:max_priority] if options.has_key?(:max_priority)
    end

    def start
      say "*** Starting IoBound job worker #{Delayed::IoBoundJob.worker_name}"

      trap('TERM') { say 'Exiting...'; $exit = true }
      trap('INT')  { say 'Exiting...'; $exit = true }

      loop do
        result = nil

        realtime = Benchmark.realtime do
          result = Delayed::IoBoundJob.work_off
        end

        count = result.sum

        break if $exit

        if count.zero?
          sleep(SLEEP)
        else
          say "#{count} IoBound jobs processed at %.4f j/s, %d failed ..." % [count / realtime, result.last]
        end

        break if $exit
      end

    ensure
      Delayed::IoBoundJob.clear_locks!
    end

  end
end
