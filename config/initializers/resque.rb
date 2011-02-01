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


# HTTP Auth For Resque Console
if Server::Application.config.http_auth_credentials
  Resque::Server.use Rack::Auth::Basic do |username, password|
   username == Server::Application.config.http_auth_credentials[:login] && 
   password == Server::Application.config.http_auth_credentials[:password]
  end
end

# pull in resque worker flags - mostly related to photos so it goes here
res_work_config = YAML::load(ERB.new(File.read("#{Rails.root}/config/resque_workers.yml")).result)[Rails.env].recursively_symbolize_keys!
Server::Application.config.resque_run_forked = res_work_config[:run_forked]

# resque looks at the environment INTERVAL to determine poll frequency
ENV['INTERVAL'] = res_work_config[:poll_interval].to_s

msg = "=> Resque options loaded. redis host is: "+  resque_config[Rails.env]
Rails.logger.info msg
puts msg


#
## add instrumentation to track resque jobs in NewRelic - this is needed since the 
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
    # Installs a hook to ensure the agent starts manually when the worker
    # starts and also adds the tracer to the process method which executes
    # in the forked task.
    module ResqueInstrumentation
      ::Resque::Job.class_eval do
        include NewRelic::Agent::Instrumentation::ControllerInstrumentation

        old_perform_method = instance_method(:perform)

        define_method(:perform) do
          class_name = (payload_class ||self.class).name
          NewRelic::Agent.reset_stats if NewRelic::Agent.respond_to? :reset_stats
          perform_action_with_newrelic_trace(:name => 'perform', :class_name => class_name,
                                             :category => 'OtherTransaction/ResqueJob') do
            old_perform_method.bind(self).call
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
