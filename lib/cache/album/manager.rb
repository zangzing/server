require 'json'
require 'cache/base'

module Cache
  module Album

    # this class manages the album cache for users - it tracks
    # what is needed for the album index page
    class Manager < Cache::Base
      unless defined? CACHE_MAX_INACTIVITY
        CACHE_MAX_INACTIVITY = 72.hours
      end

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
        invalidator.add_tracked_user(user_id, AlbumTypes::LIKED_USERS_ALBUMS_PUBLIC)
      end

      # for the user specified, invalidate any dependent
      # cache entries tied to public albums
      def invalidate_my_public_albums(invalidator, user_id)
        invalidator.add_tracked_user(user_id, AlbumTypes::MY_ALBUMS_PUBLIC)
      end

      # for the user specified, invalidate any dependent
      # cache entries tied to this user
      def invalidate_my_albums(invalidator, user_id)
        invalidator.add_tracked_user(user_id, AlbumTypes::MY_ALBUMS)
      end

      # invalidate this specific public album
      def invalidate_public_album(invalidator, album_id)
        invalidator.add_tracked_album(album_id, AlbumTypes::LIKED_ALBUMS_PUBLIC)
      end

      # invalidate this specific album
      def invalidate_liked_album(invalidator, album_id)
        invalidator.add_tracked_album(album_id, AlbumTypes::LIKED_ALBUMS)
      end

      def invalidate_invited_album(invalidator, album_id)
        invalidator.add_tracked_album(album_id, AlbumTypes::MY_INVITED_ALBUMS)
      end

      # called on entry to the top most deferral, lets us set up any
      # state we need.
      def deferred_prepare(state)
        state[:album_cache_invalidator] = DeferredInvalidator.new(self)
      end

      # we are exiting the top level deferral, so we do our actual deferred work here
      def deferred_finish(state)
        invalidator = state[:album_cache_invalidator]
        invalidator.invalidate_now if invalidator  # do the real invalidation
      end

      # fetches the appropriate invalidator type
      def make_invalidator
        # see if nested in a deferred completion, so use thread local version
        state = DeferredCompletionManager.state
        if state.empty?
          # just make a normal one since not inside DeferredCompletion
          invalidator = Invalidator.new(self)
        else
          # we are inside a deferral, get the deferred invalidator
          invalidator = state[:album_cache_invalidator]
        end
        invalidator
      end

      def album_change_matters?(album)
        @@album_fields_filter ||= Set.new [
            "privacy",
            "created_at",
            "cover_photo_id",
            "name",
            "completed_batch_count",
            "photos_last_updated_at",
            "cache_version",
            "deleted_at"
        ]
        changed = album.changed
        changed.each do |item|
          return true if @@album_fields_filter.include?(item)
        end

        return false
      end

      # invalidate the tracks for this album
      def album_invalidate(album)
        user_id = album.user_id
        album_id = album.id

        # collect all the invalidations into the Invalidator so
        # we only have to invalidate once
        invalidator = make_invalidator

        # invalidate public related trackers
        invalidate_my_public_albums(invalidator, user_id)
        invalidate_public_album(invalidator, album_id)
        invalidate_liked_user(invalidator, user_id)

        # now invalidate anything dependent on this users albums (except for public which is handled above)
        invalidate_my_albums(invalidator, user_id)

        # and finally invalidate anything dependent on this specific album
        invalidate_liked_album(invalidator, album_id)
        invalidate_invited_album(invalidator, album_id)

        # and now invalidate the caches and tracked items
        invalidator.invalidate
      end

      # invalidate the tracks for this album
      def user_invalidate_cache(user_id)
        Invalidator.flush_versions(self, user_id)
      end

      # from a given album determine which caches and state tracking needs to be invalidated
      # before calling this album_change_matters should have been checked.  We don't do it
      # here because we want this outside of the transaction and no longer know what changed.
      def album_modified(album)
        album_invalidate(album)
      end

      # called when we have been deleted - this will
      # change when we add safe delete
      def album_deleted(album)
        album_invalidate(album)
      end

      # a comment has been added for an album must bust
      # activities
      def comment_added( user_id, subject_id, subject_type )

        # collect all the invalidations into the Invalidator so
        # we only have to invalidate once
        invalidator = make_invalidator

        # invalidate public related trackers
        #invalidate_my_public_albums(invalidator, user_id)
        #invalidate_public_album(invalidator, album_id)
        #invalidate_liked_user(invalidator, user_id)

        invalidator.add_tracked_user(user_id, AlbumTypes::ACTIVITY_PUBLIC)
        invalidator.add_tracked_user(user_id, AlbumTypes::ACTIVITY)
        invalidator.add_tracked_album(subject_id, AlbumTypes::ACTIVITY)
        invalidator.add_tracked_album(subject_id, AlbumTypes::ACTIVITY_PUBLIC)

        # now invalidate anything dependent on this users albums (except for public which is handled above)
        #invalidate_my_albums(invalidator, user_id)

        # and finally invalidate anything dependent on this specific album
        #invalidate_liked_album(invalidator, album_id)
        #invalidate_invited_album(invalidator, album_id)

        # and now invalidate the caches and tracked items
        invalidator.invalidate
      end


      # a user like has been modified for the given user
      # We are changing the users we like so it doesn't really matter
      # which user change because the cache is now stale and must
      # be re-fetched when next requested which will retrack any items of interest
      def user_like_modified(user_id, tracked_user_id = nil)
        invalidator = make_invalidator
        invalidator.add_tracked_user(user_id, AlbumTypes::LIKED_USERS_ALBUMS_PUBLIC)
        invalidator.add_tracked_user_like_membership(user_id, AlbumTypes::LIKED_USERS_ALBUMS_PUBLIC)
        invalidator.invalidate
      end

      # a like for the given album for this user has changed
      # We invalidate the liked albums for this user.  The tracked_album_id
      # is not used because we delete all of them since the cache is now stale
      # and we expect the next visit for this cache to retrack the items
      # that user cares about
      def album_like_modified(user_id, tracked_album_id = nil)
        invalidator = make_invalidator
        invalidator.add_tracked_user(user_id, AlbumTypes::LIKED_ALBUMS)
        invalidator.add_tracked_album_like_membership(user_id, AlbumTypes::LIKED_ALBUMS)
        invalidator.add_tracked_user(user_id, AlbumTypes::LIKED_ALBUMS_PUBLIC)
        invalidator.add_tracked_album_like_membership(user_id, AlbumTypes::LIKED_ALBUMS_PUBLIC)
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

      def user_albums_acl_modified(user_ids)
        invalidator = make_invalidator

        user_ids.each do |user_id|
          invalidator.add_tracked_user(user_id, AlbumTypes::MY_INVITED_ALBUMS)
          invalidator.add_tracked_user_invites(user_id, AlbumTypes::MY_INVITED_ALBUMS)

          # since we don't show anything other than an empty album list for the public view, no need to notify on change
          #invalidator.add_tracked_user(user_id, AlbumTypes::MY_INVITED_ALBUMS_PUBLIC)
          #invalidator.add_tracked_user_invites(user_id, AlbumTypes::MY_INVITED_ALBUMS_PUBLIC)
        end

        invalidator.invalidate
      end

      # user has been deleted so invalidate any related caches
      def user_deleted(user_id)
        user_albums_acl_modified([user_id])
        user_like_modified(user_id)
        album_like_modified(user_id)
      end

      # trim out old entries, called by
      # a sweeper resque job
      def trim_tracker
        Invalidator.trim(self, CACHE_MAX_INACTIVITY.ago.to_i)
      end

    end

  end
end
