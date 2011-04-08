module Cache
  module Album

    class Versions
      attr_accessor :user, :user_id, :public, :my_albums, :liked_albums, :liked_users_albums

      def initialize(user = nil, public = false, my_albums = 0, liked_albums = 0, liked_users_albums = 0)
        self.user = user
        self.user_id = user.nil? ? 0 : user.id
        self.public = public
        self.my_albums = my_albums.nil? ? 0 : my_albums
        self.liked_albums = liked_albums.nil? ? 0 : liked_albums
        self.liked_users_albums = liked_users_albums.nil? ? 0 : liked_users_albums
      end

      def all_match?(my_albums, liked_albums, liked_users_albums)
        return false if self.my_albums == 0 || self.liked_albums == 0 || self.liked_users_albums == 0
        return my_albums == self.my_albums && liked_albums == self.liked_albums && liked_users_albums == self.liked_users_albums
      end

      def match?(other)
        return all_match?(other.my_albums, other.liked_albums, other.liked_users_albums)
      end

      def match_my_albums?(my_albums)
        return false if self.my_albums == 0
        return self.my_albums == my_albums
      end

      def match_liked_albums?(liked_albums)
        return false if self.liked_albums == 0
        return self.liked_albums == liked_albums
      end

      def match_liked_users_albums?(liked_users_albums)
        return false if self.liked_users_albums == 0
        return self.liked_users_albums == liked_users_albums
      end

      def my_albums_etag
        return VersionEtag.new(user_id, my_albums, public ? TrackTypes::MY_ALBUMS_PUBLIC : TrackTypes::MY_ALBUMS)
      end

      def liked_albums_etag
        return VersionEtag.new(user_id, liked_albums, public ? TrackTypes::LIKED_ALBUMS_PUBLIC : TrackTypes::LIKED_ALBUMS)
      end

      def liked_users_albums_etag
        return VersionEtag.new(user_id, liked_users_albums, TrackTypes::LIKED_USERS_ALBUMS_PUBLIC)
      end

    end

    class VersionEtag
      def initialize(user_id, ver, track_type)
        @user_id = user_id
        @ver = ver
        @track_type = track_type
      end

      def cache_key
        return Loader.make_cache_key(@user_id, @track_type, @ver)
      end
    end

  end
end

