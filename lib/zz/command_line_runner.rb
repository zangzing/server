module ZZ
  # simple class that encapsulates running commands on the command line
  class CommandLineRunner
    # run directly using the command without prepending
    # the command directory - relies on the path being set
    # up properly
    def self.run_direct(the_cmd, args)
      begin
        cmd = the_cmd + " " + args
        Rails.logger.info("CommandLine:" + cmd)
        output = `#{cmd}`
      rescue Errno::ENOENT
        raise_not_found(cmd)
      end
      if $?.exitstatus == 127
        raise_not_found(cmd)
      end
      if $?.exitstatus != 0
        msg = "Command line call for #{the_cmd} failed with #{$?.exitstatus}"
        raise ZZ::CommandLineException.new(msg)
      end
      return output
    end

    def self.raise_not_found(cmd)
      raise ZZ::CommandLineNotFound.new("Command not found for #{cmd}")
    end

    # run a command from the command directory
    def self.run(the_cmd, args)
      cmd = command_path + "/" + the_cmd
      run_direct(cmd, args)
    end

    def self.command_path
      @@command_path
    end

    def self.command_path=(cmd_path)
      @@command_path = cmd_path
    end
  end
end

