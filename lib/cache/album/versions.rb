module Cache
  module Album

    class Versions
      attr_accessor :user, :user_id, :public, :version_map

      def initialize(user = nil, public = false, version_map = {})
        self.user = user
        self.user_id = user.nil? ? 0 : user.id
        self.public = public
        self.version_map = version_map
      end

      def version(album_type)
        version = self.version_map[album_type]
        return version.nil? ? 0 : version
      end

      def match?(ver, album_type)
        version = self.version(album_type)
        return false if version == 0  # 0 never matches
        ver == version
      end

      def set_version(ver, album_type)
        self.version_map[album_type] = ver
      end

      def etag(album_type)
        return VersionEtag.new(user_id, version(album_type), album_type)
      end
    end

    class VersionEtag
      def initialize(user_id, ver, album_type)
        @user_id = user_id
        @ver = ver
        @album_type = album_type
      end

      def cache_key
        return Loader.make_cache_key(@user_id, @album_type, @ver)
      end
    end

  end
end

