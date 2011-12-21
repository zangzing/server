#!/usr/bin/env ruby

require 'app_init'
require 'optparse'
require 'yaml'

# CLI runner.
# Parse options and send command to the correct Controller.
class EMRunner
  COMMANDS            = %w(start stop)

  # Parsed options
  attr_accessor :options

  # Name of the command to be runned.
  attr_accessor :command

  # Arguments to be passed to the command.
  attr_accessor :arguments

  # Return all available commands
  def self.commands
    commands  = COMMANDS
    commands
  end

  def cfg
    AsyncConfig.config
  end

  def initialize(argv)
    @argv = argv

    # Default options values
    @options = {
      :chdir                => Dir.pwd,
      :instance_num         => 0,
      :force                => false,
      :max_conns            => Thin::Server::DEFAULT_MAXIMUM_CONNECTIONS,
      :max_persistent_conns => Thin::Server::DEFAULT_MAXIMUM_PERSISTENT_CONNECTIONS,
    }

    parse!
  end

  def parser
    # NOTE: If you add an option here make sure the key in the +options+ hash is the
    # same as the name of the command line option.
    # +option+ keys are used to build the command line to launch other processes,
    # see <tt>lib/thin/command.rb</tt>.
    @parser ||= OptionParser.new do |opts|
      opts.banner = "Usage: emstart.rb [options] #{self.class.commands.join('|')}"

      opts.separator ""
      opts.separator "Server options:"

      opts.on("-a", "--address HOST", "bind to HOST address ")                        { |host| @options[:address] = host }
      opts.on("-n", "--instance NUM", "use NUM (default: #{@options[:instance_num]})")  { |num| @options[:instance_num] = num.to_i }
      opts.on("-p", "--port PORT", "use PORT ")                                       { |port| @options[:port] = port.to_i }
      opts.on("-c", "--chdir DIR", "Change to dir before starting")                   { |dir| @options[:chdir] = File.expand_path(dir) }

      opts.on("-u", "--user NAME", "User to run as (use with -g)")             { |user| @options[:user] = user }
      opts.on("-g", "--group NAME", "Group to run as (use with -u)")           { |group| @options[:group] = group }
      opts.on("-f", "--force", "Force operation - stop -f does forced kill")           {  @options[:force] = true }

      opts.separator ""
      opts.separator "Tuning options:"

      opts.on(      "--max-conns NUM", "Maximum number of open file descriptors " +
                                       "(default: #{@options[:max_conns]})",
                                       "Might require sudo to set higher than 1024")  { |num| @options[:max_conns] = num.to_i } unless Thin.win?
      opts.on(      "--max-persistent-conns NUM",
                                     "Maximum number of persistent connections",
                                     "(default: #{@options[:max_persistent_conns]})") { |num| @options[:max_persistent_conns] = num.to_i }

      opts.on_tail('-v', '--version', "Show version")                                 { puts Thin::SERVER; exit }
    end
  end

  # Parse the options.
  def parse!
    parser.parse! @argv
    @command   = @argv.shift
    @arguments = @argv
  end

  def start
    starter = ThinStarter.new(options[:instance_num])
    address = options[:address] || starter.get_address
    port = options[:port] || starter.get_port
    starter.user = options[:user]
    starter.group = options[:group]
    starter.max_connections = options[:max_conns]
    if address.index('/') == 0
      # starts with a / so must be unix socket
      starter.stop_other_start_us(address)
    else
      starter.stop_other_start_us(address, port)
    end
  end

  def stop
    starter = ThinStarter.new(options[:instance_num])
    starter.stop_other(options[:force])
  end

  def run_command
    case command
      when 'start'
        start
      when 'stop'
        stop
    end
  end

  # Parse the current shell arguments and run the command.
  # Exits on error.
  def run!
    if self.class.commands.include?(@command)
      run_command
    elsif @command.nil?
      puts "Command required"
      puts @parser
      exit 1
    else
      abort "Unknown command: #{@command}. Use one of #{self.class.commands.join(', ')}"
    end
  end
end

#def run(argv = ARGV)
#  exit_code = true
#  begin
#    runner = EMRunner(argv)
#    runner.run!
#  rescue Exception => ex
#    exit_code = false
#    puts ex.message
#  end
#
#  # make sure buffer is flushed
#  # debugger doesn't seem to do this always
#  STDOUT.flush
#
#  return exit_code
#end

EMRunner.new(ARGV).run!