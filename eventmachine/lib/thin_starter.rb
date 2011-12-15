# some helper methods to start off the async thin server
class ThinStarter
  attr_accessor :user, :group, :max_connections
  attr_reader :instance_num

  def initialize(instance_num)
    @instance_num = instance_num
    @server = nil
    @stopping = false
    @user = nil
    @group = nil
    @max_connections = nil
    setup_sigs
  end

  def setup_sigs
    trap('INT')  { stop }
    trap('TERM') { stop }
    trap('QUIT') { stop }
    trap('HUP')  {  }
  end

  def stop
    if @stopping == false && @server
      AsyncConfig.logger.info "Shutdown signal received"
      # only top the server once
      @stopping = true
      remove_self_pid_file(get_pid_path)
      # Set up a one shot failsafe timer to shut ourselves down
      # if we don't exit gracefully within the failsafe window.
      # This can happen if one or more downloads are still running
      # and they do not complete within the failsafe time.  We don't
      # want to be kept around indefinitely so we exit immediately
      # if we hit the end of the window.
      EventMachine::add_timer(cfg[:failsafe_timeout]) {
        AsyncConfig.logger.info("Failsafe timer forced termination")
        # unwind and then exit
        EventMachine::next_tick {
          exit!
        }
      }
      @server.stop
    end
  end

  def cfg
    AsyncConfig.config
  end

  # builds up our address based on our instance
  # number and whether we are a unix socket or tcp socket
  def get_address
    server_address = cfg[:server_address]
    if server_address.index('/') == 0
      # server address is a unix socket so add on the instance number and .sock
      "#{server_address}#{@instance_num}.sock"
    else
      # a normal tcp address just return it
      server_address
    end
  end

  def get_port
    cfg = AsyncConfig.config
    port = cfg[:server_base_port]
    port.nil? ? nil : port + instance_num
  end

  def get_pid_path
    "#{cfg[:pid_run_dir]}/#{cfg[:pid_file_prefix]}#{instance_num}.pid"
  end

  # read the pid file
  # return the pid or nil
  def read_pid_file(file)
    pid = File.read(file).to_i rescue nil
  end

  def write_pid(file)
    remove_pid_file(file)
    open(file,"w") { |f| f.write(Process.pid) }
    File.chmod(0644, file)
  end

  def remove_pid_file(file)
    File.delete(file) rescue nil
  end

  def remove_self_pid_file(file)
    current_pid = read_pid_file(file)
    remove_pid_file(file) if Process.pid == current_pid
  end

  def send_signal(signal, pid, timeout=60)
    AsyncConfig.logger.info "Sending #{signal} signal to process #{pid} ... "
    Process.kill(signal, pid)
    SystemTimer.timeout(timeout) do
      sleep 0.1 while Process.running?(pid)
    end
  rescue Timeout::Error
    AsyncConfig.logger.info "Timeout!"
  rescue Exception
    AsyncConfig.logger.info "Process still running: #{pid}"
  end

  # used to simply stop another instance and return
  def stop_other(force = false)
    pid_file = get_pid_path
    pid = read_pid_file(pid_file)

    if pid
      signal = force ? 'KILL' : 'QUIT'
      send_signal(signal, pid, 1)
    end
  end

  # send a graceful stop to the other instance
  # if it is running, we trust it to stop on its
  # own since it might have long running jobs
  # but we do expect it to give up the address
  # it is holding
  def stop_other_start_us(*args)
    args << {:signals => false}

    AsyncConfig.logger.info "Process Id: #{Process.pid}"

    pid_file = get_pid_path
    pid = read_pid_file(pid_file)

    # now write our pid file
    write_pid(pid_file)

    give_up_at = Time.now.to_i + cfg[:max_wait_for_address]
    still_starting = true
    while still_starting && Time.now.to_i < give_up_at
      if pid
        # send it a kill signal and a small window to
        # let it quit, ok if it doesn't quit we just
        # want to take over the listing address
        send_signal('QUIT', pid, 1)
      end
      # see if we can start the server
      begin
        still_starting = false  # assume will start
        start_server(*args)
      rescue Exception => ex
        msg = ex.message
        puts msg
        if msg == 'no acceptor'
          still_starting = true
          sleep 0.5
        end
      end
    end
    if still_starting
      # we tried to get the address for the max timeout with no luck
      # so the other server is not acting nice.  We need to forcefully
      # take it from the other server now by terminating it
      AsyncConfig.logger.error("Existing server did not give up address, forcefully killing #{pid}")
      send_signal('KILL', pid, 5)
      sleep 5
      # and last try before we give up
      begin
        start_server(*args)
      rescue Exception => ex
        AsyncConfig.logger.error("Unable to start eventmachine async server")
      end
    end
    # read from the pid file and if it's us we can remove it, otherwise leave it
    # since somebody else has taken over control
    remove_self_pid_file(pid_file)
  end

  # allocate a new thread and kick start the server,
  # this is useful for test cases where we want to
  # have the server up and running to be able to
  # test against it
  def start_for_test(address = '0.0.0.0', port = 3031)
    @async_thread = Thread.new do
      start_server(address, port)
    end
    # cheezy wait till server is up and running
    while running? == false
      sleep 0.2
    end
  end

  def running?
    @server.nil? == false && @server.running?
  end

  # Change privileges of the process
  # to the specified user and group.
  def change_privilege(user, group=user)
    AsyncConfig.logger.info ">> Changing process privilege to #{user}:#{group}"

    uid, gid = Process.euid, Process.egid
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid

    if uid != target_uid || gid != target_gid
      # Change process ownership
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue Errno::EPERM => e
    AsyncConfig.logger.info "Couldn't change user and group to #{user}:#{group}: #{e}"
    raise e
  end

  # starts the server in the current thread, this does
  # not return until it is ready to exit
  # takes either a single server for a unix socket
  # or a server ip and port
  def start_server(*args)
    AsyncConfig.logger.info("Event Machine App started")

    @server = RouteManager.create_routes(*args)
    # max time we will allow for idle to client
    @server.timeout = cfg[:client_timeout]
    @server.maximum_connections = max_connections if max_connections
    @server.log_file = cfg[:thin_log_file]
    # apply the config and then change effective user if requested
    # this is so you can start off as sudo to allow things like large number of connections
    # and then run safely as a specific user and group
    @server.config
    change_privilege(@user, @group) if @user

    # now running as the intended user, so safe to start using zza
    zza = ZZ::ZZA.new
    zza.track_event('event_machine.start')

    @server.start!
  end

end
