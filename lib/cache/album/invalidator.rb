module Cache
  module Album

    # this class tracks the invalidations given
    # and then modifies the database and any
    # dependent versions
    class Invalidator
      attr_accessor :cache_man, :tracker

      def initialize(cache_man)
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

      # this tracks changes to the viewer/contrib album acl for a given user
      def add_tracked_user_invites(user_id, track_type)
        tracker.add([user_id, TrackTypes::USER_INVITES, track_type])
      end

      # Invalidate the tracks and related versions
      # in the db.  Also deletes the tracks from
      # the database.
      def invalidate_now
        return if tracker.length == 0
        # used for our intermediate results on delete
        tx_id = Manager.next_tx_id
        begin
          db = cache_man.db
          # Fetch the set of unique user_ids and track_types that the current trackers affect
          # we put the result into a working set table so we can update our versions to 0 and
          # delete any related tracking rows
          cmd =   "INSERT INTO c_working_track_set(user_id, track_type, tx_id) "
          cmd <<  "(SELECT distinct t.user_id, t.track_type, #{tx_id} FROM c_tracks t INNER JOIN c_versions v ON v.user_id = t.user_id AND v.track_type = t.track_type WHERE "
          rows = tracker.to_a
          RawDB.fast_multi_execute(db, rows, ['t.tracked_id', 't.tracked_id_type', 't.track_type'], cmd, ')')


          # Delete the tracked items - they will be recreated the next time a user tries to
          # fetch from their cache.  This query deletes all the entries for a given user of the given type that
          # was affected.  So, if you like 5 albums but only one changes, all the tracks for like albums for you
          # are dropped because until the cache is rebuilt it doesn't matter what happens to those other albums
          #
          # Delete the tracks before the versions are updated.  If done in the opposite order, you could potentially
          # lose tracks that came in after the version change and miss changes to those tracks.  We do this since
          # we don't want to have to run this as a transaction due to potentially blocking many callers on a lock.
          #
          cmd =   "DELETE c_tracks FROM c_tracks INNER JOIN c_working_track_set "
          cmd <<  "ON c_tracks.user_id = c_working_track_set.user_id AND c_tracks.track_type = c_working_track_set.track_type "
          cmd <<  "WHERE c_working_track_set.tx_id = #{tx_id}"
          results = cache_man.execute(cmd)

          # invalidate versions related to album or user changes
          cmd =   "UPDATE c_versions v INNER JOIN c_working_track_set w ON v.user_id = w.user_id AND v.track_type = w.track_type "
          cmd <<  "SET v.ver = 0 WHERE w.tx_id = #{tx_id}"
          results = cache_man.execute(cmd)

          # delete the working set
          cmd =   "DELETE FROM c_working_track_set WHERE tx_id = #{tx_id}"
          results = cache_man.execute(cmd)

        rescue Exception => ex
          cache_man.logger.info("Error while invalidating cache: #{ex.message}")
        ensure
          tracker.clear
        end
      end

      def invalidate
        invalidate_now
      end

      # Flush the cache for a specific user
      def self.flush_versions(cache_man, user_id)
        begin
          db = cache_man.db

          # remove old versions
          cmd =   "DELETE FROM c_versions WHERE user_id = #{db.quote(user_id)}"
          results = cache_man.execute(cmd)

        rescue Exception => ex
          cache_man.logger.info("Error while flushing cache: #{ex.message}")
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

          # remove old tracked items
          # Remove tracked and then versions in that order since the versions affect
          # the tracks.  We want to make sure that new changes to the tracks
          # are not lost.
          cmd =   "DELETE FROM c_tracks WHERE user_last_touch_at < #{older_than}"
          results = cache_man.execute(cmd)

          # remove old versions
          cmd =   "DELETE FROM c_versions WHERE user_last_touch_at < #{older_than}"
          results = cache_man.execute(cmd)

        rescue Exception => ex
          cache_man.logger.info("Error while trimming cache: #{ex.message}")
        end
      end

    end

  end
end


