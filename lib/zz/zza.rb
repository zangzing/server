require 'json'
require 'monitor'
require 'net/http'
require 'uri'
require 'system_timer'

module ZZ
  # This module is self contained and includes all the management and
  # data delivery functionality for delivering ZZA events to the ZZA
  # server.
  #
  # It supports persistent events that can survive across any ZZA server
  # outages as it queues small batches of files for future delivery
  # inside its working directory.  It is thread safe and can operate
  # properly with multiple senders.  This simplifies the runtime requirements
  # since you don't have to have a separate worker process to send the data.
  # As long as there is at least one sender thread running somewhere in the
  # system the messages will get delivered eventually.
  #

  # this is the worker thread responsible for delivering the events to
  # the ZZA server.  This should be created as a singleton
  # since there should only be one of these per
  # process.  This is created by initialization code in this class.
  # You can also initialize it with ZZ::ZZA.initialize which will create it.
  #
  # You can also call the ZZA.default_zza_id= method which will ensure
  # you get a default zza_id set and will initialize if not already done
  # If a sender has already been created the existing one will be used.
  # This way, we always keep just one copy running.
  #
  # This class also provides the thread safe primitives for batching the
  # requests created by the ZZA class so that multiple ZZA instances can
  # share common output files and benefit by the flush timers to batch
  # requests.
  #
  class ZZASender
    attr_reader :zza_unreachable_count

    # how often our worker thread wakes up to process events
    SEND_SWEEP_TIME = 5

    # the maximum time we are willing to let a file that says
    # it is in use remain so.  If it exceeds this time it is
    # presumably because it's process died.
    IN_USE_MAX_TIME = 5 * 60

    # after how many messages we issue a flush - there is little
    # performance cost to doing this on each line so we do so because
    # it decreases the chances of losing any data on a crash
    FLUSH_AFTER_COUNT = 1

    # the maximum number of events we will push into a single file
    # this puts a cap on how big of a request we end up pushing up
    # to the ZZA server
    MAX_EVENTS_PER_FILE = 2500

    # our working directory
    ZZA_TEMP_DIR = "/data/tmp/zza"

    # file suffix to indicate it is currently in use
    # and should not have its contents sent yet
    IN_USE = "inuse"
    IN_USE_STRIPPER = /(.*)-inuse$/

    # the address of the ZZA server
    ZZA_URI = URI.parse("http://zza.zangzing.com/")

    # the maximum time we are willing to wait before
    # completing our request
    ZZA_MAX_TIME = 30

    def initialize
      # create a monitor for file operations
      @file_lock = Monitor.new
      # the file we will send on
      @file = nil
      @zza_unreachable_count = 0

      # make the temp dir if not already there
      `mkdir -p #{ZZA_TEMP_DIR}`

      # now run the main sender loop
      @send_thread = Thread.new do
        run_send_loop
      end
    end

    # we can't rely on the rails logger since this code
    # is meant to work everywhere so just output to stdout
    def log(msg)
      puts msg rescue nil
    end

    # true if this thread is aborting
    def thread_aborting?
      Thread.current.status == "aborting"
    end

    def thread
      @send_thread
    end

    # let someone outside wake us up
    # now - useful for testing
    # returns true if the last batch
    # actually had work
    def run
      @send_thread.run
    end

    def has_work?
      @file.nil? == false || has_files
    end

    def run_send_loop
      # prep the connection to zza
      @http = Net::HTTP.new(ZZA_URI.host, ZZA_URI.port)

      while thread_aborting? == false do
        begin
          #log Time.now.to_s + ": ZZA Sender checking files up: " + Process.pid.to_s
          # first close out the current file so we can send it
          close_current_file

          # now send data from any ready files
          send_files_data
          #log Time.now.to_s + ": ZZA Sender going to sleep: " + Process.pid.to_s

          # sleep to let the data accumulate again
          sleep SEND_SWEEP_TIME

        rescue Exception => ex
          log "Error in ZZA sender: " + ex.message
        ensure
          if thread_aborting?
            # make an attempt to clean up
            close_current_file rescue nil
          end
        end
      end
    end

    # for testing just check to see if we have pending files
    # just stop if we have at least one
    # THIS IS A TEST HOOK ONLY
    def has_files
      # first gather all the file is this directory
      files = Dir.entries(ZZA_TEMP_DIR)

      files.each do |file_path|

        full_path = ZZA_TEMP_DIR + "/" + file_path

        if File.directory?(full_path) == false

          parts = file_path.split('-')

          # if file structure not valid skip this one
          next if parts.count < 3 and parts.count > 4

          created_at = parts[0].to_i

          if (parts.last() != IN_USE || (created_at <= too_old))
            return true
          end
        end
      end
      return false
    end

    # clean up an in use file that has been orphaned
    # by adding the closing json and renaming the file
    # so it is not recovered again
    def recover_in_use_file(file, full_path)
      file.seek(0, IO::SEEK_END)
      append_json_close_data(file)
      file.flush
      # and rename to indicate we have appended json data
      full_path =~ IN_USE_STRIPPER
      new_path = $1
      File.rename(full_path, new_path) rescue nil
      # position back to start
      file.seek(0, IO::SEEK_SET)

      return new_path
    end


    # Scan the work directory and pick up all files that are not
    # in use.  As a special case we will process any -inuse files
    # that are older than IN_USE_MAX_TIME
    #
    # if we spend too long in here we will close the current file
    # to avoid having it show in use for too long
    def send_files_data
      sends_attempted = 0
      # close the current file if we've been here beyond the time limit
      close_current_at = Time.now().to_i + SEND_SWEEP_TIME

      # anything in use older than this is fair game to claim
      too_old = Time.now().to_i - IN_USE_MAX_TIME

      # first gather all the file is this directory
      files = Dir.entries(ZZA_TEMP_DIR)

      files.each do |file_path|

        # cap our max time here to avoid keeping current inuse file active too long
        # so return true which will claim the latest file and continue
        if Time.now().to_i >= close_current_at
          close_current_file
          # next point we should close
          close_current_at = Time.now().to_i + SEND_SWEEP_TIME
        end

        full_path = ZZA_TEMP_DIR + "/" + file_path

        if File.directory?(full_path) == false

          parts = file_path.split('-')

          # if file structure not valid skip this one
          next if parts.count < 3 and parts.count > 4

          created_at = parts[0].to_i
          in_use = parts.last() == IN_USE
          if (in_use == false || (created_at <= too_old))
            begin
              # ok, we have a file to work with
              # see if we can get a lock on it, if not just
              # ignore and pick it up next time
              file = File.open(full_path, "r+")
              # non blocking attempt to get lock
              got_lock = file.flock(File::LOCK_EX|File::LOCK_NB)
              if (got_lock)
                # see if this was a file not closed properly
                if in_use
                  # file was never properly closed so write
                  # closure data to end, rename, and rewind
                  full_path = recover_in_use_file(file, full_path)
                end
                # we got the lock so now extract and send
                sends_attempted += 1
                send_zza_data(file)

                # delete before the close to ensure no one
                # else tries to pick up this file since
                # closing releases the lock
                File.delete(full_path) rescue nil

              end
            rescue Errno::ENOENT => ex
              # this is an expected condition
              # since another process may have grabbed
              # the file before we could open or lock it
            rescue Exception => ex
              log "Error in ZZA send_files_data: " + ex.message
            ensure
              file.close rescue nil
            end
          end
        end
      end
      sends_attempted
    end

    # send the data up to the zza server as a stream
    def send_zza_data file
      SystemTimer.timeout_after(ZZA_MAX_TIME) do

        # send the data
        req = Net::HTTP::Post.new(ZZA_URI.path)
        req.content_type = 'application/json'
        req['Content-Length'] = file.stat.size
        req.body_stream = file
        resp = @http.request(req)

        # make sure valid
        if resp.code.to_i != 200
          raise "ZZA Send Failed with HTTP Error: " + resp.code
        end

        # ok, we got the message through so clear unreachable counter
        @zza_unreachable_count = 0
      end
    rescue Exception => ex
      # ZZA may be down, increment the zza_unreachable count
      @zza_unreachable_count += 1
      log "Unable to send to ZZA server: " + ex.message
      raise ex
    end

    # append the closing json data
    def append_json_close_data file
        # close out the data with final json array and map closure
        file.puts("]}") rescue nil
    end

    # close out the current file and clear out the file reference
    # the caller outside of this thread will detect the nil file
    # handle and make a new file.  This way we only create new files
    # after we've closed out the previous when someone actually needs one
    # to write into.
    def close_current_file
      @file_lock.synchronize do
        if @file.nil? == false

          # close out the data with final json array and map closure
          # if we have data - technically we should always have at least
          # one line so the count check is not strictly needed
          append_json_close_data(@file) if @entry_count > 0

          # rename to path without inuse flag
          new_path = ZZA_TEMP_DIR + "/" + @file_name
          old_path = @file.path
          @file.close rescue nil
          @file = nil

          # rename happens after the close to ensure
          # we are done with it before it is fair game
          # to be read and deleted by a sender thread
          File.rename(old_path, new_path) rescue nil
        end
      end
    end

    # create what should be a unique file name for our purposes
    # and encode the create time within the name
    def make_file_name create_time
      file_name = "#{create_time}-#{rand(9999999999)}-#{Process.pid}"
    end

    # this method will return the currently open file or make
    # a new one as needed
    def ensure_current_file
      @file_lock.synchronize do
        if @file.nil?
          @file_create_time = Time.now.to_i
          @file_name = make_file_name @file_create_time
          path = ZZA_TEMP_DIR + "/" + @file_name
          # For a new file we tack on the .inuse flag to indicate
          # that this file is being written to.  The file is also
          # locked.  It is possible for us to crash in which case it
          # is up to the file reader to detect this condition based on
          # the age of the file being older than IN_USE_MAX_TIME.  In that
          # case it will go ahead and treat the file as if it were closed
          # if it can obtain the lock
          create_lock_path = path + "-" + IN_USE
          @file = File.new(create_lock_path, File::RDWR|File::CREAT)
          # get exclusive access
          @file.flock(File::LOCK_EX)
          @entry_count = 0
        end
        @file
      end
    end

    # Take the passed json string and write it do
    # a queue file.  This method is thread safe.
    def post_to_file(json_str)
      @file_lock.synchronize do
        file = ensure_current_file
        if @entry_count == 0
          # For efficiency begin building the final form of the json
          # string directly in the file.  This means we don't have to
          # do anything with the data when we are ready to send other
          # than use the string directly.
          mod_str = '{"evts":[' + json_str
        else
          # not the first line so prepend a comma to seperate the
          # array we are building
          mod_str = ',' + json_str
        end
        file.puts(mod_str) rescue nil
        @entry_count += 1
        # after every FLUSH_AFTER_COUNT entry go ahead and flush
        # helps keep file in consistent state and minimize loss
        # if we have a hard crash in this process
        if @entry_count % FLUSH_AFTER_COUNT == 0
          file.flush rescue nil
        end
        if @entry_count >= MAX_EVENTS_PER_FILE
          # we've reached the upper bounds so close
          # the current one which will cause a new
          # file to open next time
          close_current_file
        end
      end
    end

    # package up the event as a json string and add to output file
    def track_event(zza_id, event, xdata, transaction_id, user_type, user, referrer_uri, page_uri, ip_address, zzv_id)
      evt = {
          :s => zza_id,
          :e => event,
          :i => transaction_id,
          :t => (Time.now.to_f * 1000).round,
          :u => user,
          :v => user_type,
          :r => referrer_uri,
          :x => xdata,
          :p => page_uri,
          :ip => ip_address,
          :zzv_id => zzv_id
      }
      json_str = JSON.generate(evt)
      post_to_file(json_str)
    end
  end

  # this class manages the creation and queueing of events.
  class ZZA
    attr_accessor :transaction_id, :referrer_uri, :page_uri, :user_type, :user, :xdata, :ip_address, :zzv_id
    attr_reader :zza_id

    # create the initial infrastructure
    def self.initialize(default_zza_id)
      @@default_zza_id ||= default_zza_id
      @@sender ||= ZZASender.new
    end

    # this should really be called explicitly in
    # cases where we have been forked such as
    # running on Unicorn.  EngineYard controls
    # that file and while we could take it over
    # we can wait till we move to Amazon since
    # our work around is to make this check
    # on each track_event call
    # TODO: take control of Unicorn config files later...
    def self.after_fork_check
      thread_state = sender.thread.status
      if !thread_state
        # thread is not running kick start a new one
        @@sender = ZZASender.new
      end
    end

    # you can set up a default to use for all instances
    # unless they individually supply it - this has
    # a side effect of doing an initialize if not
    # already done
    def self.default_zza_id=(zza_id)
      @@default_zza_id = zza_id
      initialize(zza_id)
    end

    def self.default_zza_id
      @@default_zza_id
    end

    def self.sender
      @@sender
    end

    # returns true if ZZA cannot currently be reached
    # this is used by health_check
    def self.unreachable?
      return sender.zza_unreachable_count != 0
    end

    # now the instance based methods
    # these let you send individual events

    # create the object and take an optional
    # zza_id that overrides the default
    def initialize(zza_id = nil)
      zza_id = @@default_zza_id if zza_id.nil?
      @zza_id = zza_id
    end

    # send an event - you can either pass the items you want
    # directly or if you have defaults that you use you can set them
    # first with the individual accessor methods.  Any time you pass a nil
    # for one of the attributes we will pick use the data stored with this
    # object instead.  So if you commonly use the same user_type and user you might:
    # z = ZZ::ZZA.new
    # z.user = 'someuser'
    # z.user_type = 1
    #
    # and then call as
    # z.track_event('event')
    #
    # this will pick up the saved values for all attributes except event and
    # in this case pick up the user and user_type you set on the object
    #
    def track_event(event, xdata = nil, user_type = nil, user = nil, referrer_uri = nil, page_uri = nil, ip_address = nil, zzv_id = nil)
      ZZA.after_fork_check
      xdata = self.xdata if xdata.nil?
      user_type = self.user_type if user_type.nil?
      user = self.user if user.nil?
      referrer_uri = self.referrer_uri if referrer_uri.nil?
      page_uri = self.page_uri if page_uri.nil?
      ip_address = self.ip_address if ip_address.nil?
      zzv_id = self.zzv_id if zzv_id.nil?

      ZZA.sender.track_event(zza_id, event, xdata, nil, user_type, user, referrer_uri, page_uri, ip_address, zzv_id)
    end

    # same as above but tracks a transaction - a set of related operations
    def track_transaction(event, transaction_id, xdata = nil, user_type = nil, user = nil, referrer_uri = nil, page_uri = nil, ip_address = nil, zzv_id = nil)
      ZZA.after_fork_check
      xdata = self.xdata if xdata.nil?
      transaction_id = self.transaction_id if transaction_id.nil?
      user_type = self.user_type if user_type.nil?
      user = self.user if user.nil?
      referrer_uri = self.referrer_uri if referrer_uri.nil?
      page_uri = self.page_uri if page_uri.nil?
      ip_address = self.ip_address if ip_address.nil?
      zzv_id = self.zzv_id if zzv_id.nil?

      ZZA.sender.track_event(zza_id, event, xdata, transaction_id, user_type, user, referrer_uri, page_uri,ip_address,zzv_id)
    end


  end
end

# initialize in case no one else does
# you can set the proper zza_id by calling
# the default_zza_id= method
ZZ::ZZA.initialize("ruby/svr")
