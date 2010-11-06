module ZangZing
  module Async

  class PiconUpdate < Base
      @queue = :image_processing
      
      def self.perform( album_id )
       album = Album.find( album.id )
       album.picon.clear unless album.picon.nil?
       album.picon = Picon.build( album )
       album.save
      end

    end
  end
end