module ZZ
  # simple class that encapsulates running commands on the command line
  class CommandLineRunner
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation

    # used so we can have a single instance and wrap with
    # NewRelic instrumentation
    def self.get_instance
      @@runner ||= CommandLineRunner.new
    end


    def self.raise_not_found(cmd, args)
      raise ZZ::CommandLineNotFound.new("Command not found for: #{cmd} #{args}")
    end

    # run directly using the command without prepending
    # the command directory - relies on the path being set
    # up properly
    def run_direct(the_cmd, cmd_path, args)
      perform_action_with_newrelic_trace( :name => 'external_command_' + the_cmd,
                                          :category => ZangZingConfig.new_relic_category_type,
                                          :params => { :args => args }) do
        begin
          args = "" if args.nil?
          if args.empty?
            full_cmd = cmd_path
          else
            full_cmd = cmd_path + " " + args
          end
          Rails.logger.info("CommandLine:" + full_cmd)
          output = `#{full_cmd}`
        rescue Errno::ENOENT
          ZZ::CommandLineRunner.raise_not_found(cmd_path, args)
        end
        status = $?.exitstatus
        if status == 127
          ZZ::CommandLineRunner.raise_not_found(cmd_path, args)
        end
        if status != 0
          msg = "Command line: #{the_cmd} failed with #{status} : #{output}"
          raise ZZ::CommandLineException.new(msg)
        end
        return output
      end
    end

    # low level direct run
    def self.run_cmd(cmd)
      get_instance.run_direct(cmd, cmd, nil)
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

    # return a full command with the path
    def self.build_command(cmd)
      return command_path + "/" + cmd
    end
  end
end

