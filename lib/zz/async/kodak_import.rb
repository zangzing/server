module ZZ
  module Async

    class KodakImport < GeneralImport

      def self.enqueue( photo_id, source_url, auth_token )
          super( photo_id, source_url, auth_token )
      end

      def self.perform( photo_id, source_url, auth_token)
        photo = Photo.find(photo_id)
        if photo.assigned?
          kodak_connector = KodakConnector.new(auth_token)
          photo.local_image = kodak_connector.response_as_file(source_url)
          photo.save
        end
      end

    end

  end
end