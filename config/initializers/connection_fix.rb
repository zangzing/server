# If your workers are inactive for a long period of time, they'll lose
# their MySQL connection.
#
# This hack ensures we re-connect whenever a connection is
# lost. Because, really. why not?
#
# Stick this in RAILS_ROOT/config/initializers/connection_fix.rb (or somewhere similar)
#
# From:
#   http://coderrr.wordpress.com/2009/01/08/activerecord-threading-issues-and-resolutions/

module ActiveRecord::ConnectionAdapters
  class Mysql2Adapter
    alias_method :execute_without_retry, :execute

    # see if we should attempt a reconnect
    def zz_should_retry(connect_attempts, msg)
      return false if connect_attempts >= 4

      return true if msg.nil?
      return true if msg.index("MySQL server has gone away")
      return true if msg.index("This connection is still waiting for a result, try again")

      return false
    end

    def execute(*args)
      connect_attempts = 1
      begin

        reconnect! if @connection.nil?
        execute_without_retry(*args)

      rescue Timeout::Error => e
        msg = e.message
        Rails.logger.error("MySQL SystemTimeout Error while in database operation, disconnecting: #{msg}")
        # We disconnect since the SystemTimeout could interrupt the database connection code and leave it
        # in an unknown state.  Disconnecting allows us to handle the next request cleanly.
        # In addition we have a failsafe in the zz_should_retry code that tries to detect bad state
        # and reconnect at that point as well.  It's better to catch the issue here whenever possible
        # since this prepares what should be a clean connection for next time.  Because we disconnect, we
        # now detect a nil connection and do the reconnect on the next use of this class.
        #
        # We don't use reconnect because the database itself could be the issue and reconnecting could
        # end up taking a very long time, exceeding the original timeout.
        disconnect!
        raise e
      rescue Exception => e
        msg = e.message
        if zz_should_retry(connect_attempts, msg)
          Rails.logger.error("MySQL Server connection error, reconnecting in connection_fix: #{msg}")
          connect_attempts += 1
          reconnect!
          retry
        else
          raise e
        end
      end
    end
  end
end
