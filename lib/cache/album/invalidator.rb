module Cache
  module Album

    # this class tracks the invalidations given
    # and then modifies the database and any
    # dependent versions
    class Invalidator
      attr_accessor :user_id, :cache_man, :tracker

      def initialize(cache_man, user_id)
        self.user_id = user_id
        self.cache_man = cache_man

        # this tracks the albums that need to be updated in the database for
        # our current dependencies
        self.tracker = Set.new()
      end

      # add a tracked user element
      def add_tracked_user(user_id, track_type)
        tracker.add([user_id, TrackTypes::USER, track_type])
      end

      # this tracks changes to the like users membership
      def add_tracked_user_like_membership(user_id, track_type)
        tracker.add([user_id, TrackTypes::USER_LIKE_MEMBERSHIP, track_type])
      end

      # add a tracked album element
      def add_tracked_album(album_id, track_type)
        tracker.add([album_id, TrackTypes::ALBUM, track_type])
      end

      # this tracks changes to the album like membership for
      # a given user
      def add_tracked_album_like_membership(user_id, track_type)
        tracker.add([user_id, TrackTypes::ALBUM_LIKE_MEMBERSHIP, track_type])
      end

      # Invalidate the tracks and related versions
      # in the db.  Also deletes the tracks from
      # the database.
      def invalidate
        return if tracker.length == 0
        # used for our intermediate results on delete
        tx_id = Manager.next_tx_id
        begin
          db = cache_man.db
          db.begin_db_transaction

          # Fetch the set of unique user_ids and track_types that the current trackers affect
          # we put the result into a working set table so we can update our versions to 0 and
          # delete any related tracking rows
          cmd =   "INSERT INTO working_track_set(user_id, track_type, tx_id) "
          cmd <<  "(SELECT distinct t.user_id, t.track_type, #{tx_id} FROM tracks t INNER JOIN versions v ON v.user_id = t.user_id AND v.track_type = t.track_type WHERE "
          first = true
          tracker.each do |t|
            tracked_id = t[0]
            tracked_id_type = t[1]
            track_type = t[2]
            cmd << " OR " unless first
            first = false
            cmd << "(t.tracked_id = #{tracked_id} AND t.tracked_id_type = #{tracked_id_type} AND t.track_type = #{track_type})"
          end
          cmd << ")"
          results = cache_man.execute(cmd)


          # invalidate versions related to album or user changes
          cmd =   "UPDATE versions v INNER JOIN working_track_set w ON v.user_id = w.user_id AND v.track_type = w.track_type "
          cmd <<  "SET v.ver = 0 WHERE w.tx_id = #{tx_id}"
          results = cache_man.execute(cmd)

          # now delete the tracked items - they will be recreated the next time a user tries to
          # fetch from their cache.  This query deletes all the entries for a given user of the given type that
          # was affected.  So, if you like 5 albums but only one changes, all the tracks for like albums for you
          # are dropped because until the cache is rebuilt it doesn't matter what happens to those other albums
          #
          # The following DELETE actually deletes both the items from the tracks table and the working_track_set together
          cmd =   "DELETE working_track_set, tracks FROM tracks INNER JOIN working_track_set "
          cmd <<  "ON tracks.user_id = working_track_set.user_id AND tracks.track_type = working_track_set.track_type "
          cmd <<  "WHERE working_track_set.tx_id = #{tx_id}"
          results = cache_man.execute(cmd)

          db.commit_db_transaction
        rescue Exception => ex
          db.rollback_db_transaction
          cache_man.log.info("Error while invalidating cache: #{ex.message}")
        ensure
          tracker.clear
        end
      end

      # Invalidate all tracks and related versions
      # based on age earlier than the timestamp
      # given.  This is meant to be called by
      # a sweeper task to keep the tracker trimmed
      # against users that have not shown up
      # for some long period of time.  Otherwise
      # tracks could build up indefinitely.
      def self.trim(cache_man, older_than)
        begin
          db = cache_man.db
          db.begin_db_transaction

          # first remove any versions related to old tracks
          cmd =   "DELETE versions v INNER JOIN tracks t ON v.user_id = t.user_id AND v.track_type = t.track_type "
          cmd <<  "WHERE t.user_last_touch < #{older_than}"
          results = cache_man.execute(cmd)

          # now delete the tracked items
          cmd =   "DELETE FROM tracks WHERE t.user_last_touch < #{older_than}"
          results = cache_man.execute(cmd)

          db.commit_db_transaction
        rescue Exception => ex
          db.rollback_db_transaction
          cache_man.log.info("Error while trimming cache: #{ex.message}")
        end
      end

    end

  end
end


