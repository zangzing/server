#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
#   From suggestions found in https://github.com/defunkt/resque/blob/master/README.markdown

require 'resque/server'
require 'resque-retry'
require 'resque-retry/server'


if defined?(Rails.root) and File.exists?("#{Rails.root}/config/resque.yml")

  resque_config =   YAML::load_file("#{Rails.root}/config/resque.yml")
  Resque.redis = resque_config[Rails.env]
else
     abort %{ZangZing config/resque.yml file not found. UNABLE TO INITIALIZE QUEUEING SYSTEM!}
end


#  Auth For Resque Console
class Authentication
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    session = request.session
    user_id = session['user_credentials_id']
    user = User.find_by_id( user_id )
    if user && user.admin?
      @app.call(env)
    else
      [401, {"Content-Type" => "text/html", "Location" => "/service"}, ["Not Authorized: Insufficient Privileges"]]
    end
  end
end
Resque::Server.use Authentication



# pull in resque worker flags - mostly related to photos so it goes here
res_work_config = YAML::load(ERB.new(File.read("#{Rails.root}/config/resque_workers.yml")).result)[Rails.env].recursively_symbolize_keys!
Server::Application.config.resque_run_forked = res_work_config[:run_forked]

# resque looks at the environment INTERVAL to determine poll frequency
ENV['INTERVAL'] = res_work_config[:poll_interval].to_s

msg = "=> Resque options loaded. redis host is: "+  resque_config[Rails.env]
Rails.logger.info msg
puts msg

# monkey patch method that calls for to not run a new process if
# resque_run_forked flag is set.
#
# Also temporary fix for EY verbose script bug.
#
module Resque
  # A Resque Worker processes jobs. On platforms that support fork(2),
  # the worker will fork off a child to process each job. This ensures
  # a clean slate when beginning the next job and cuts down on gradual
  # memory growth as well as low level failures.
  #
  # It also ensures workers are always listening to signals from you,
  # their master, and can react accordingly.
  class Worker
    def startup
      # work around bug introduced by EY startup scripts where they turn on Verbose environment vars
      self.verbose = false
      self.very_verbose = false

      enable_gc_optimizations
      register_signal_handlers
      prune_dead_workers
      run_hook :before_first_fork
      register_worker

      # Fix buffering so we can `rake resque:work > resque.log` and
      # get output from the child in there.
      $stdout.sync = true
    end

    def working_on(job)
      Thread.current[:resque_job] = job
      job.worker = self
      data = encode \
        :queue   => job.queue,
        :run_at  => Time.now.to_s,
        :payload => job.payload
      redis.set("worker:#{self}", data)
    end

    # Not every platform supports fork. Here we do our magic to
    # determine if yours does.
    def fork
      @cant_fork = true if ::Server::Application.config.resque_run_forked == false

      return if @cant_fork

      begin
        # IronRuby doesn't support `Kernel.fork` yet
        if Kernel.respond_to?(:fork)
          Kernel.fork
        else
          raise NotImplementedError
        end
      rescue NotImplementedError
        @cant_fork = true
        nil
      end
    end
  end
end


# add instrumentation to track resque jobs in NewRelic - this is needed since the
# standard tracking expects resque jobs to be running out of forked instances
# and deosn't track the parent.  In our case we would like to run the workers
# directly from the parent due to the significantly lower overhead and the
# fact that we are monitoring the parent with monit anyways so it should
# be able to kill off misbehaved instances
#
module ZZInstrument
  module Instrumentation
    # == Resque Instrumentation
    #
    module ResqueInstrumentation
      ::Resque::Job.class_eval do
        include NewRelic::Agent::Instrumentation::ControllerInstrumentation

        old_perform_method = instance_method(:perform)

        define_method(:perform) do
          class_name = (payload_class ||self.class).name
          NewRelic::Agent.reset_stats if Server::Application.config.resque_run_forked && (NewRelic::Agent.respond_to? :reset_stats)
          perform_action_with_newrelic_trace(:name => 'perform', :class_name => class_name,
                                             :category => 'OtherTransaction/ResqueJob') do
            DeferredCompletionManager.dispatch {old_perform_method.bind(self).call}
            #old_perform_method.bind(self).call
          end

          if Server::Application.config.resque_run_forked
            NewRelic::Agent.shutdown unless defined?(::Resque.before_child_exit)
          end
        end
      end

      if defined?(::Resque.before_child_exit)
        ::Resque.before_child_exit do |worker|
          NewRelic::Agent.shutdown unless Server::Application.config.resque_run_forked == false
        end
      end
    end
  end
end if defined?(::Resque::Job)

