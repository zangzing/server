module ZZ
  module Async

    class UpdatePicon < Base
      @queue = :image_processing

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

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