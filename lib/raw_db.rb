# Low level raw database access
# these are all static methods and expect you to pass
# in the database connection object for each call.
#
class RawDB
  # Query the largest safe message size, mostly relevant to
  # bulk insert so it can determine where to break requests
  def self.safe_max_size(db, padding = 64 * 1024)
    result = db.execute("show variables like 'max_allowed_packet'")
    return result.first[1].to_i - padding
  end


  # wrap the db execute method
  def self.execute(db, cmd)
    db.execute(cmd)
  end

  # a fast batch insert
  # you provide the base command string such as:
  # "INSERT INTO tracks(user_id, tracked_id, track_type, user_last_touch_at) VALUES "
  # and an option end command to be added after all the values such as:
  # " ON DUPLICATE KEY UPDATE user_last_touch_at = VALUES(user_last_touch_at)"
  # This call will build a batch insert from your rows which is expected to
  # be an array of arrays with the innermost array holding a row of data.  The
  # order of the values must match the order specified in the base command
  # string passed in.  In the example above the order would be 0: user_id,
  # 1: tracked_id, 2: track_type
  #
  def self.fast_insert(db, safe_max_db_size, rows, base_cmd, end_cmd = '')
    return if rows.empty?
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
        vcmd << (value.nil? ? 'NULL' : db.quote(value.to_s))
      end
      vcmd << ')'
      cmd << vcmd

      if cmd.length > safe_max_db_size
        # over the safe limit so execute this one now
        cmd << end_cmd
        result = execute(db, cmd)
        cmd = base_cmd.dup
        cur_rows = 0
      end
    end
    # and do last batch if needed
    if cur_rows > 0
      cmd << end_cmd
      result = execute(db, cmd)
    end

    result
  end

end