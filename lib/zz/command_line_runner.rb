module ZZ
  # simple class that encapsulates running commands on the command line
  class CommandLineRunner
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation

    # used so we can have a single instance and wrap with
    # NewRelic instrumentation
    def self.get_instance
      @@runner ||= CommandLineRunner.new
    end

    # run directly using the command without prepending
    # the command directory - relies on the path being set
    # up properly
    def run_direct(the_cmd, cmd_path, args)

      perform_action_with_newrelic_trace( :name => 'external_command_' + the_cmd,
                                          :category => ZangZingConfig.new_relic_category_type,
                                          :params => { :args => args }) do
        begin
          full_cmd = cmd_path + " " + args
          Rails.logger.info("CommandLine:" + full_cmd)
          output = `#{full_cmd}`
        rescue Errno::ENOENT
          raise_not_found(cmd_path)
        end
        if $?.exitstatus == 127
          raise_not_found(cmd_path)
        end
        if $?.exitstatus != 0
          msg = "Command line call for #{the_cmd} failed with #{$?.exitstatus}"
          raise ZZ::CommandLineException.new(msg)
        end
        return output
      end
    end

    def self.raise_not_found(cmd)
      raise ZZ::CommandLineNotFound.new("Command not found for #{cmd}")
    end

    # run a command from the command directory
    def self.run(the_cmd, args)
      cmd_path = command_path + "/" + the_cmd
      get_instance.run_direct(the_cmd, cmd_path, args)
    end

    def self.command_path
      @@command_path
    end

    def self.command_path=(cmd_path)
      @@command_path = cmd_path
    end
  end
end

