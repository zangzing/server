require 'active_record'
require 'active_record/connection_adapters/mysql2_adapter'
require 'app/models/bulk_id_generator'

module Cache

    # Base class for caching
    class Base
      attr_accessor

      # initialize the cache manager, optionally takes the
      # database config options
      # we don't actually connect at this point
      # it is done the first time we fetch the db object
      # or explicitly via new_connection
      #
      def initialize(config = nil)
        if config.nil?
          @db_config = CacheDatabaseConfig.config.dup
        else
          @db_config = config.dup
        end
        @db = nil
      end

      def logger
        Rails.logger
      end

      # next transaction id within the cache db
      def self.next_tx_id
        BulkIdManager.next_id_for('cache_tx_generator')
      end

      # get a new database connection with the
      # options passed in at init time
      # this is mainly used internally and
      # after forking to ensure we get new connections
      #
      def new_connection
        old_db_id = @db.nil? ? 0 : @db.object_id
        @db.disconnect! unless @db.nil?

        @db = ActiveRecord::Base.mysql2_connection(@db_config)

        new_db_id = @db.object_id
        logger.info("New cache db connection - old db id was: #{old_db_id} -- new db id is: #{new_db_id}")

        result = @db.execute("show variables like 'max_allowed_packet'")
        @safe_max_size = result.first[1].to_i - (32 * 1024)

        return @db
      end

      # fetch the current or an on demand new instance
      # of the database connection
      def db
        @db ||= new_connection
      end

      # wrap the db execute method
      def execute(cmd)
        db.execute(cmd)
      end

      # a fast batch insert
      # you provide the base command string such as:
      # "INSERT INTO tracks(user_id, tracked_id, track_type, user_last_touch_at) VALUES "
      # and an option end command to be added after all the values such as:
      # " ON DUPLICATE KEY UPDATE user_last_touch_at = VALUES(user_last_touch_at)"
      # This call will build a batch insert from your rows which is expected to
      # be an array of arrays with the innermost array holding a row of data.  The
      # order of the values msut match the order specified in the base command
      # string passed in.  In the example above the order would be 0: user_id,
      # 1: tracked_id, 2: track_type
      #
      def fast_insert(rows, base_cmd, end_cmd = '')
        result = nil
        cmd = base_cmd.dup
        cur_rows = 0
        rows.each do |row|
          cmd << "," if cur_rows > 0
          cur_rows += 1

          vcmd = '('
          first = true
          row.each do |value|
            vcmd << ',' unless first
            first = false
            vcmd << value.to_s
          end
          vcmd << ')'
          cmd << vcmd

          if cmd.length > self.safe_max_db_size
            # over the safe limit so execute this one now
            cmd << end_cmd
            result = db.execute(cmd)
            cmd = base_cmd.dup
            cur_rows = 0
          end
        end
        # and do last batch if needed
        if cur_rows > 0
          cmd << end_cmd
          result = execute(cmd)
        end

        result
      end

    protected

      # the max size (with some slop) that you should
      # create for a single message to the database
      # this is used by fast_insert to know when to break
      # the requests for very large sets of rows
      def safe_max_db_size
        @safe_max_size
      end

    end

end
