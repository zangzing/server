module ZZ
  module Async
    
    class AlbumShare < Base
      @queue = :io_bound
      
      def self.enqueue( share_id )
        super( share_id )
      end  

      def self.perform( share_id )
        share = Share.find(share_id)
        share.deliver
      end

    end
    
  end
end
