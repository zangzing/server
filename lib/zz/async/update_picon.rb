module ZZ
  module Async

    class UpdatePicon < Base
      @queue = :image_processing

      def self.enqueue( album_id )
          super( album_id )
      end

      def self.perform( album_id )
        album = Album.find( album_id )
        album.update_picon
      end

    end
  end
end