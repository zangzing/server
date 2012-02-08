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

  # cache this so we only do it once
  # as long as all database server are configured
  # the same way it's ok to treat them all the same
  def self.global_max_size(db)
    @@global_max_size ||= safe_max_size(db)
  end

  # wrap the db execute method
  def self.execute(db, cmd)
#    puts cmd
    db.execute(cmd)
  end

  def self.build_in_clause(db, rows)
    cur_rows = 0
    vcmd = '('
    rows.each do |row|
      vcmd << "," if cur_rows > 0
      cur_rows += 1
      vcmd << (row.nil? ? 'NULL' : db.quote(row.to_s))
    end
    vcmd << ')'
    vcmd
  end

  # flatten result set into an array of single items
  def self.single_values(rows)
    results = []
    rows.each do |row|
      results << row[0]
    end
    results
  end

  # extract the single result
  def self.single_value(rows)
    rows.first[0]
  end

  # extract the single row result
  def self.single_row(rows)
    rows.first
  end

  def self.append_rows(result, rows)
    return if rows.nil?
    rows.each do |row|
      result << row
    end
  end

  def self.as_rows(rows)
    result = []
    append_rows(result, rows)
    result
  end

  # a fast multi part select, can operate with a multi part key
  # but does it by building a set of AND clauses separated
  # by OR rather than a multi column IN clause.  Multi column
  # IN clauses do not optimize properly in mysql
  # this call will break the call up over multiple executions
  # if need be based on max packet size
  # call with an array of column names and then a subsequent of
  # array of arrays for each rows value
  #
  # takes the names and rows and builds an IN clause like condition but
  # does it in the for of (a AND b) OR (a1 AND b1) because mysql
  # does not optimize multi in clause statements of the form (f1, f2) in ((v1,v2),(v3,v4))
  #
  # It is up to the caller to filter out any duplicates if needed
  #
  def self.fast_multi_execute(db, rows, names, base_cmd, end_cmd = '')
    return [] if rows.empty?
    result = []
    # empirical testing has shown that we want to keep the max statement for the condition to a reasonable size
    # so 32k bytes seems to be a good happy medium
    max_stmt_size = [32768, global_max_size(db)].min

    cmd = base_cmd.dup
    cmd << '('
    cur_rows = 0
    rows.each do |row|
      cmd << " OR " if cur_rows > 0
      cur_rows += 1

      vcmd = '('
      first = true
      i = 0
      names.each do |name|
        value = row[i]
        i += 1
        vcmd << ' AND ' unless first
        first = false
        vcmd << (value.nil? ? "#{name} IS NULL" : "#{name}=#{db.quote(value.to_s)}")
      end
      vcmd << ')'
      cmd << vcmd

      if cmd.length > max_stmt_size
        # over the safe limit so execute this one now
        cmd << ')'
        cmd << end_cmd
        rows = execute(db, cmd)
        append_rows(result, rows)
        cmd = base_cmd.dup
        cmd << '('
        cur_rows = 0
      end
    end
    # and do last batch if needed
    if cur_rows > 0
      cmd << ')'
      cmd << end_cmd
      rows = execute(db, cmd)
      append_rows(result, rows)
    end

    result
  end


  # a fast batch delete, can operate with a multi part key
  # but does it by building a set of AND clauses separated
  # by OR rather than a multi column IN clause.  Multi column
  # IN clauses do not optimize properly in mysql
  # this call will break the delete up over multiple deletes
  # if need be based on max packet size
  # call with an array of column names and then a subsequent of
  # array of arrays for each rows value
  def self.fast_delete(db, rows, names, table)
    base_cmd = "DELETE FROM #{table} WHERE "
    fast_multi_execute(db, rows, names, base_cmd)
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
  def self.fast_insert(db, rows, base_cmd, end_cmd = '')
    return if rows.empty?
    result = nil
    cmd = base_cmd.dup
    cur_rows = 0
    safe_max_db_size = global_max_size(db)
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