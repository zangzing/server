##
# A Ruby client library for memcached.
#

class MemCache
  def nowait(key)
    server = get_server_for_key(key)
    server.nowait
  end

  protected unless $TESTING

  ##
  # Gets or creates a socket connected to the given server, and yields it
  # to the block, wrapped in a mutex synchronization if @multithread is true.
  #
  # If a socket error (SocketError, SystemCallError, IOError, Timeout) or protocol error
  # (MemCacheError) is raised by the block, closes the socket, attempts to
  # connect again, and retries the block (once).  If an error is again raised,
  # reraises it as MemCacheError.
  #
  # If unable to connect to the server (or if in the reconnect wait period),
  # raises MemCacheError.  Note that the socket connect code marks a server
  # dead for a timeout period, so retrying does not apply to connection attempt
  # failures (but does still apply to unexpectedly lost connections etc.).

  def with_socket_management(server, &block)
    check_multithread_status!

    @mutex.lock if @multithread
    retried = false

    begin
      socket = server.socket

      # Raise an IndexError to show this server is out of whack. If were inside
      # a with_server block, we'll catch it and attempt to restart the operation.

      raise IndexError, "No connection to server (#{server.status})" if socket.nil?

      block.call(socket)

    rescue SocketError, Errno::EAGAIN => err
      logger.warn { "Socket failure: #{err.message}" } if logger
      server.mark_dead(err)
      handle_error(server, err)

    rescue MemCacheError, SystemCallError, IOError, Timeout::Error => err
      logger.warn { "Generic failure: #{err.class.name}: #{err.message}" } if logger
      handle_error(server, err) if retried || socket.nil?
      retried = true
      retry
    end
  ensure
    @mutex.unlock if @multithread
  end


  ##
  # This class represents a memcached server instance.

  class Server

    ##
    # The amount of time to wait before attempting to re-establish a
    # connection with a server that is marked dead.

    ZZ_RETRY_DELAY = 5.0

    def mark_dead(error)
      close
      @retry  = Time.now + ZZ_RETRY_DELAY

      reason = "#{error.class.name}: #{error.message}"
      @status = sprintf "%s:%s DEAD (%s), will retry at %s", @host, @port, reason, @retry
      @logger.info { @status } if @logger
    end

    # don't make us wait to try again
    def nowait
      @retry = nil
    end

  end


end
