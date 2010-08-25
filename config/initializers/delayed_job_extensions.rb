require 'delayed_job'
require 'cpu_bound_job'
require 'cpu_bound_worker'
require 'io_bound_job'
require 'io_bound_worker'


module Delayed
  module MessageSending

    def send_later(method, job_class, *args) #Redefined to support custom job types (subclasses of Delayed::Job)
      klass = job_class.is_a?(Class) ? job_class : job_class.to_s.constantize!
      #Delayed::Job.enqueue Delayed::PerformableMethod.new(self, method.to_sym, args)
      klass.enqueue Delayed::PerformableMethod.new(self, method.to_sym, args)
    end

  end
end
