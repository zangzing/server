require 'json'
require 'cache/base'

module Cache
  module Album

    # this class manages the album cache for users - it tracks
    # what is needed for the album index page
    class Manager < Cache::Base
      KEY_PREFIX = "Cache.Album.".freeze

      CACHE_MAX_INACTIVITY = 72.hours

      # make a shared instance
      def self.make_shared
        @@shared ||= Manager.new()
      end

      # get the shared instance
      def self.shared
        @@shared
      end

      # make a loader that can be used to fetch
      # albums from cache or db as needed
      def make_loader(user, public)
        loader = Loader.new(self, user, public)
      end

      # for the user specified, invalidate any dependent
      # cache entries tied to public albums
      def invalidate_liked_user(invalidator, user_id)
        invalidator.add_tracked_user(user_id, TrackTypes::LIKED_USERS_ALBUMS_PUBLIC)
      end

      # for the user specified, invalidate any dependent
      # cache entries tied to public albums
      def invalidate_my_public_albums(invalidator, user_id)
        invalidator.add_tracked_user(user_id, TrackTypes::MY_ALBUMS_PUBLIC)
      end

      # for the user specified, invalidate any dependent
      # cache entries tied to this user
      def invalidate_my_albums(invalidator, user_id)
        invalidator.add_tracked_user(user_id, TrackTypes::MY_ALBUMS)
      end

      # invalidate this specific public album
      def invalidate_public_album(invalidator, album_id)
        invalidator.add_tracked_album(album_id, TrackTypes::LIKED_ALBUMS_PUBLIC)
      end

      # invalidate this specific album
      def invalidate_album(invalidator, album_id)
        invalidator.add_tracked_album(album_id, TrackTypes::LIKED_ALBUMS)
      end

      def album_change_matters?(album)
        @@album_fields_filter ||= Set.new [
            "privacy",
            "created_at",
            "cover_photo_id",
            "name",
            "completed_batch_count",
            "photos_last_updated_at",
            "deleted_at"
        ]
        changed = album.changed
        changed.each do |item|
          return true if @@album_fields_filter.include?(item)
        end

        return false
      end

      # if we have been safe deleted in the past return true
      def previously_deleted?(album)
        return (!album.deleted_at.nil? && album.deleted_at_changed? == false) ? true : false
      end

      # from a given album determine which caches and state tracking needs to be invalidated
      def album_modified(album)
        # first check to make sure the change is something we care about
        return unless album_change_matters?(album)

        return if previously_deleted?(album)

        user_id = album.user_id
        album_id = album.id

        # collect all the invalidations into the Invalidator so
        # we only have to invalidate once
        invalidator = Invalidator.new(self, user_id)

        # a change to public visibility happened if we are public and
        # at least one batch has completed
        album_is_public_visible = album.privacy == "public" && album.completed_batch_count > 0

        # if we are publicly visible or we just became private
        # we must invalidate
        public_visibility_changed = album_is_public_visible ||
              (album.privacy_changed? && (album.changed_attributes['privacy'] == "public"))

        # invalidate proper trackers if a change to public visibility
        if public_visibility_changed || album.is_safe_deleted?
          invalidate_my_public_albums(invalidator, user_id)
          invalidate_public_album(invalidator, album_id)
          invalidate_liked_user(invalidator, user_id)
        end

        # now invalidate anything dependent on this users albums (except for public which is handled above)
        invalidate_my_albums(invalidator, user_id)

        # and finally invalidate anything dependent on this specific album
        invalidate_album(invalidator, album_id)

        # and now invalidate the caches and tracked items
        invalidator.invalidate
      end

      # a user like has been modified for the given user
      # We are changing the users we like so it doesn't really matter
      # which user change because the cache is now stale and must
      # be re-fetched when next requested which will retrack any items of interest
      def user_like_modified(user_id, tracked_user_id)
        invalidator = Invalidator.new(self, user_id)
        invalidator.add_tracked_user(user_id, TrackTypes::LIKED_USERS_ALBUMS_PUBLIC)
        invalidator.add_tracked_user_like_membership(user_id, TrackTypes::LIKED_USERS_ALBUMS_PUBLIC)
        invalidator.invalidate
      end

      # a like for the given album for this user has changed
      # We invalidate the liked albums for this user.  The tracked_album_id
      # is not used because we delete all of them since the cache is now stale
      # and we expect the next visit for this cache to retrack the items
      # that user cares about
      def album_like_modified(user_id, tracked_album_id)
        invalidator = Invalidator.new(self, user_id)
        invalidator.add_tracked_user(user_id, TrackTypes::LIKED_ALBUMS)
        invalidator.add_tracked_album_like_membership(user_id, TrackTypes::LIKED_ALBUMS)
        invalidator.add_tracked_user(user_id, TrackTypes::LIKED_ALBUMS_PUBLIC)
        invalidator.add_tracked_album_like_membership(user_id, TrackTypes::LIKED_ALBUMS_PUBLIC)
        invalidator.invalidate
      end

      # a remove or add has happened, we don't really care which
      # but we do care what was affected
      def like_modified(user_id, like)
        subject_type = like.subject_type
        subject_id = like.subject_id
        case subject_type
          when Like::USER
            user_like_modified(user_id, subject_id)
          when Like::ALBUM
            album_like_modified(user_id, subject_id)
        end

      end

      # called when a like is added
      def like_added(user_id, like)
        like_modified(user_id, like)
      end

      # called when a like is removed
      def like_removed(user_id, like)
        like_modified(user_id, like)
      end

      # trim out old entries, called by
      # a sweeper resque job
      def trim_tracker
        Invalidator.trim(self, CACHE_MAX_INACTIVITY.ago.to_i)
      end

    end

  end
end
