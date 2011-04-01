# this class manages the album cache for users - it tracks
# what is needed for the album index page
class AlbumCacheManager
  require 'json'
  require 'redis'
  require 'config/initializers/zangzing_config'

  attr_accessor :redis

  KEY_PREFIX = "albums.cache."

  USERS_PUBLIC_ALBUMS = "upa".freeze

  VERSIONS_KEY = "versions".freeze

  # make a shared instance
  def self.make_shared
    @@shared ||= AlbumCacheManager.new()
  end

  # get the shared instance
  def self.shared
    @@shared
  end

  def initialize
    self.redis = make_redis
  end

  # todo: make this work with more than one
  def make_redis
#    server = RedisConfig.config[:redis_cache_servers]
#    parts = server.split(':')
#    host = parts[0]
#    port = parts[1]
#    db = parts[2].nil? ? 0 : parts[2]
#    Redis.new(:host => host, :port => port, :db => db)
  end

  # albums that should be shown to the current users (not a guest)
  def current_user_albums(user, user_albums_ver, liked_albums_ver, liked_users_ver)
    user_id = user.id

    albums = check_cache("users_albums", user_albums_ver)
    if albums.nil?
      albums = user.albums
      user_albums_ver = set_cache("users_albums", albums)
    end

    liked_albums = check_cache("liked_albums", user_albums_ver)
    if liked_albums.nil?
      liked_albums = user.liked_albums
      liked_albums_ver = set_cache("liked_albums", liked_albums)
    end

    liked_users_albums = check_cache("liked_users_public_albums", liked_users_ver)
    if albums.nil?
      liked_users_albums = user.liked_users_public_albums
      liked_users_ver = set_cache("liked_users_public_albums", liked_users_albums)
    end

    result = {
        :albums             => { :ver => user_albums_ver, :albums => albums },
        :liked_albums       => { :ver => liked_albums_ver, :albums => liked_albums },
        :liked_users_albums => { :ver => liked_users_ver, :albums => liked_users_albums }
    }
  end

  # public albums to be shown for a specific user
  # this will return the json if the cache is out of date, or nil if they
  # already have the latest
  def guest_user_albums(user, user_albums_ver, liked_albums_ver, liked_users_ver)
    user_id = user.id
    vers = get_current_versions(user_id)

    cur_user_albums_ver = vers[USERS_PUBLIC_ALBUMS]
    cur_liked_albums_ver = vers["liked_public_albums"]
    cur_liked_users_ver = vers["liked_users_public_albums"]

    if  (cur_user_albums_ver == user_albums_ver) &&
        (cur_liked_albums_ver == liked_albums_ver) &&
        (cur_liked_users_ver == liked_users_ver)
      return nil  # nothing to fetch
    end

    need_ver_update = false

    if albums = fetch_cache(USERS_PUBLIC_ALBUMS, cur_user_albums_ver) == nil
      albums = user.albums.where("privacy = 'public' AND completed_batch_count > 0")
      user_albums_ver = set_cache(USERS_PUBLIC_ALBUMS, albums)
      need_ver_update = true
    end

    liked_albums = check_cache("liked_public_albums", user_albums_ver)
    if liked_albums.nil?
      liked_albums = albums_to_hash(user.liked_public_albums)
      liked_albums_ver = set_cache("liked_public_albums", liked_albums)
      need_ver_update = true
    end

    liked_users_albums = check_cache("liked_users_public_albums", liked_users_ver)
    if albums.nil?
      liked_users_albums = user.liked_users_public_albums
      liked_users_ver = set_cache("liked_users_public_albums", liked_users_albums)
      need_ver_update = true
    end


    result = {
        :albums             => { :ver => user_albums_ver, :albums => albums },
        :liked_albums       => { :ver => liked_albums_ver, :albums => liked_albums },
        :liked_users_albums => { :ver => liked_users_ver, :albums => liked_users_albums }
    }

    if (need_ver_update)
      save_current_versions(user_id, ver)
    end
  end

  def make_key(part_key)
    # prepend our namespace
    KEY_PREFIX + part_key
  end

  def rails_cache
    Rails.cache
  end

  # save the current versions from the cache for this user
  def save_current_versions(user_id, ver)
    key = make_key("#{VERSIONS_KEY}.#{user_id}")
    json = JSON.fast_generate
    rails_cache.write(key, json)
  end

  # get the current versions from the cache for this user
  def get_current_versions(user_id)
    key = make_key("#{VERSIONS_KEY}.#{user_id}")
    versions_json = rails_cache.read(key)
    if !versions_json.nil?
      return JSON.parse(versions_json)
    end

    return {}
  end

  # this method returns the album as a map which allows us to perform
  # very fast json conversion on it
  def albums_to_hash(albums)
#    - album id
#    - album name
#    - cover photo thumb url
#    - cover photo thumb width and height (rotated)
#    - if you are not sorting on server, then i will need last-mod-date

    # first grab all the cover photos in one query
    # this populates the albums in place
    Album.fetch_bulk_covers(albums)

    # we keep a local map of the user_id to name because in most
    # cases the albums will have the same user - avoids lots of
    # Activerecord overhead
    user_id_to_name_map = {}

    fast_albums = []
    albums.each do |album|
      album_cover = album.cover
      album_id = album.id
      album_name = album.name
      album_updated_at = album.updated_at
      cover_rotated_width = album_cover.rotated_width
      cover_rotated_height = album_cover.rotated_height

#      album_user_id = album.user_id.to_s
#      album_user_name = user_id_to_name_map[album_user_id]
#      if album_user_name.nil?
#          # don't have it, go to the db and get it
#          album_user_name = album.user.username
#          user_id_to_name_map[album_user_id] = album_user_name
#      end

      hash_album = {
          :id => album_id,
          :name => album_name,
          :c_url => album_cover.nil? ? nil : album_cover.thumb_url,
          :c_width => album_cover.nil? ? nil : cover_rotated_width,
          :c_height => album_cover.nil? ? nil : cover_rotated_height,
          :updated_at => album_updated_at
      }
      fast_albums << hash_album
    end

    return fast_albums
  end

  # from the given user determine which caches and state tracking needs to be invalidated
  # NOT SURE We Need this one
  def user_modified(user)

  end

  # for the user specified, invalidate any dependent
  # cache entries tied to public albums
  def invalidate_users_public_albums(user_id, album_id)

  end

  # invalidate this specific public album
  def invalidate_public_album(user_id, album_id)

  end

  # for the user specified, invalidate any dependent
  # cache entries tied to albums
  def invalidate_users_albums(user_id, album_id)

  end

  # invalidate this specific album
  def invalidate_album(user_id, album_id)

  end

  def album_change_matters?(album)
    @@album_fields_filter ||= Set.new [
        "privacy",
        "created_at",
        "cover_photo_id",
        "name",
        "completed_batch_count",
        "updated_at"
    ]
    changed = album.changed
    changed.each do |item|
      return true if @@album_fields_filter.include?(item)
    end

    return false
  end

  # from a given album determine which caches and state tracking needs to be invalidated
  def album_modified(album)
    # first check to make sure the change is something we care about
    return unless album_change_matters?(album)

    user_id = album.user_id
    album_id = album.id


    # determine if a change to public visibility
    if album.privacy_changed?
      if album.privacy == "public" || album.changed_attributes['privacy'] == "public"
        # privacy changed from or to public
        invalidate_users_public_albums(user_id, album_id)
        invalidate_public_album(user_id, album_id)
      end
    end

    # now invalidate anything dependent on this users albums (except for public which is handled above)
    invalidate_users_albums(user_id, album_id)

    # and finally invalidate anything dependent on this specific album
    invalidate_album(user_id, album_id)
  end

  # a user like has been modified for the given user
  def user_like_modified(user_id, subject_user_id)

  end

  # a like for the given album for this user has changed
  def album_like_modified(user_id, subject_album_id)

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
end