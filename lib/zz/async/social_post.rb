module ZZ
  module Async
    
    class SocialPost < Base
      @queue = :io_bound
      
      def self.enqueue( share_id, url_to_share )
        super( share_id, url_to_share )
      end  

      def self.perform( share_id, url_to_share )
        share = Share.find(share_id)
        share.link_to_share = url_to_share
        share.deliver
      end

    end
    
  end
end