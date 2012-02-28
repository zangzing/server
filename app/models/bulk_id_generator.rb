# this class manages primary key ids for the specified table
# This is needed for tables where we want to use bulk inserts
# and have the ids without having to make a trip back to the database
# if you go this route, you must always manually request the id
# because we turn the auto increment feature off for these tables
class BulkIdGenerator  < ActiveRecord::Base
  # return the next id batch range using optimistic locking
  # once we have the range, the caller can hand out ids up to
  # between first and last
  def self.next_id_batch(table_name)

  end
end

# this class holds the range
# the only assumption we have is that
# ranges cannot start with zero since that
# is a special value that we use to indicate
# no current range
class BulkIdRange
  attr_accessor :last, :next

  def initialize table_name
    @table_name = table_name
    @range_lock = Monitor.new
    @next = 0  # no data yet
  end

  # return the next id, in most cases
  # we can simply return the next value
  # from memory, if we go beyond the last
  # we must go back to the database for a
  # new range
  #
  # this method is thread safe
  #
  def next_id(reserved_count)
    the_id = 0  # need this here since used in
                # lock scope
    range_lock.synchronize do
      if @next == 0 || (@next + reserved_count > @last)
        # time for a new range
#        BulkIdGenerator.transaction do
          get_new_range(reserved_count)
#        end
      end
      the_id = @next
      @next += reserved_count  # for next time around
    end

    return the_id
  end

private

  def convert_isolation(iso)
    case iso
      when 'READ-COMMITTED'
        return 'READ COMMITTED'
      when 'READ-UNCOMMITTED'
        return 'READ UNCOMMITTED'
      when 'REPEATABLE-READ'
        return 'REPEATABLE READ'
      else
        return iso
    end
  end

  def get_new_range(reserved_count)
    begin
      # since this is an optimistic lock it is possible that someone
      # else snuck in.  If so we get an exception telling us the update
      # was stale so we will keep trying till no longer stale
      previous_isolation = nil
      previous_isolation = convert_isolation(BulkIdGenerator.connection.execute("SELECT @@tx_isolation").first[0])
      BulkIdGenerator.connection.execute("SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED")

      try_again = true
      while try_again do
        begin
          try_again = false # assume we will get it
          get_new_range_optimistically(reserved_count)
        rescue ActiveRecord::StaleObjectError => ex
          # need to try again
          try_again = true
        end
      end
    rescue Exception => ex
      # any other type of exception means we did not get
      # our range so invalidate it and reraise the exception
      @next = 0
      raise ex
    ensure
      if previous_isolation.nil? == false
        BulkIdGenerator.connection.execute("SET SESSION TRANSACTION ISOLATION LEVEL #{previous_isolation}") rescue nil
      end
    end
  end

  # get the new range from the database without regard for the lock
  def get_new_range_optimistically(reserved_count)
    id_gen = nil
    BulkIdGenerator.uncached do
      id_gen = BulkIdGenerator.find_by_table_name(@table_name)
    end
    @next = id_gen.next_start_id
    # take the db batch size suggestion or if not large enough get reserved_count amount
    batch_size = id_gen.batch_size > reserved_count ? id_gen.batch_size : reserved_count
    @last = @next + batch_size - 1
    # set the next start value in the database
    id_gen.next_start_id = @next + batch_size
    id_gen.save
  end

  def range_lock
    @range_lock
  end
end


# a thread safe Id manager for bulk ids
class BulkIdManager
  # the table to range mappings

  # return the next id for the given
  # table, internally may cause a
  # database call to take place
  #
  # if you want to ensure more than 1,
  # specify the amount you want via the reserved_count
  # if we don't have enough left in our
  # current range, we will fetch a continuous
  # range of ids from the db in a single call
  #
  # WARNING: Never call this from within
  # a transaction because failure of that
  # transaction could cause us to rollback
  # ids without our knowledge meaning
  # the range we fetched from the database
  # would be invalid and would result in
  # duplicates.
  #
  # If you plan on using transaction (remember, a save itself
  # happens in a transaction which means the before_save etc
  # callbacks are unsafe), allocate your ids up front
  #
  def self.next_id_for(table_name, reserved_count = 1)
    range = tables[table_name]
    if range.nil?
      # obtain the lock to create a new table entry
      manager_lock.synchronize do
        # now that we have the lock, make sure somebody
        # else didn't sneak in before us and create it
        if range.nil?
          # make a new entry for this table
          range = BulkIdRange.new(table_name)
          tables[table_name] = range
        end
      end
    end
    # happens outside of the table lock
    # since the ranges have their own individual locks
    range.next_id(reserved_count)
  end


  private

  def self.manager_lock
    # this is the monitor to protect access to
    # modification of the manager table
    # the individual ranges also have locks
    # so we can have concurrency between different
    # tables - overkill for our essentially
    # single threaded rails world but hey what the heck...
    #
    @@id_lock ||= Monitor.new
  end

  def self.tables
    @@tables ||= {}
  end

end