
module Delayed
  class IoBoundWorker < Worker

    self.sleep_delay = 5
    self.max_attempts = 25
    self.max_run_time = 4.hours

    def self.backend=(backend)
      if backend.is_a? Symbol
        require "delayed/backend/#{backend}"
        backend = "Delayed::Backend::#{backend.to_s.classify}::IoBoundJob".constantize
      end
      @@backend = backend
      silence_warnings { ::Delayed.const_set(:IoBoundJob, backend) }
    end

    # Every worker has a unique name which by default is the pid of the process. There are some
    # advantages to overriding this with something which survives worker retarts:  Workers can#
    # safely resume working on tasks which are locked by themselves. The worker will assume that
    # it crashed before.

    def start
      say "*** Starting IoBoundJob worker #{name}"

      trap('TERM') { say 'Exiting...'; $exit = true }
      trap('INT')  { say 'Exiting...'; $exit = true }

      loop do
        result = nil

        realtime = Benchmark.realtime do
          result = work_off
        end

        count = result.sum

        break if $exit

        if count.zero?
          sleep(@@sleep_delay)
        else
          say "#{count} jobs processed at %.4f j/s, %d failed ..." % [count / realtime, result.last]
        end

        break if $exit
      end

    ensure
      Delayed::IoBoundJob.clear_locks!(name)
    end

   # Reschedule the job in the future (when a job fails).
    # Uses an exponential scale depending on the number of failed attempts.
    def reschedule(job, time = nil)
      if (job.attempts += 1) < self.class.max_attempts
        time ||= IoBoundJob.db_time_now + (job.attempts ** 4) + 5
        job.run_at = time
        job.unlock
        job.save!
      else
        say "* [IO JOB] PERMANENTLY removing #{job.name} because of #{job.attempts} consecutive failures.", Logger::INFO

        if job.payload_object.respond_to? :on_permanent_failure
          say "* [IO JOB] Running on_permanent_failure hook"
          job.payload_object.on_permanent_failure
        end

        self.class.destroy_failed_jobs ? job.destroy : job.update_attributes(:failed_at => Delayed::IoBoundJob.db_time_now)
      end
    end

  protected

    # Run the next job we can get an exclusive lock on.
    # If no jobs are left we return nil
    def reserve_and_run_one_job

      # We get up to 5 jobs from the db. In case we cannot get exclusive access to a job we try the next.
      # this leads to a more even distribution of jobs across the worker processes
      job = Delayed::IoBoundJob.find_available(name, 5, self.class.max_run_time).detect do |job|
        if job.lock_exclusively!(self.class.max_run_time, name)
          say "* [Worker(#{name})] acquired lock on #{job.name}"
          true
        else
          say "* [Worker(#{name})] failed to acquire exclusive lock for #{job.name}", Logger::WARN
          false
        end
      end

      run(job) if job
    end

  end
end
