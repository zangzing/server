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
  class MysqlAdapter
    alias_method :execute_without_retry, :execute

    def execute(*args)
      execute_without_retry(*args)
    rescue => e
      msg = e.message
      if msg && msg.index("MySQL server has gone away")
        Rails.logger.error("MySQL Server connection timed out, retrying in connection_fix")
        reconnect!
        retry
      else
        raise e
      end
    end
  end
end
