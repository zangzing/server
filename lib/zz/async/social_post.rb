module ZZ
  module Async
    
    class SocialPost < Base
      @queue = :io_bound
      
      def self.enqueue( share_id, url_to_share )
        super( share_id, url_to_share )
      end  

      def self.perform( share_id, url_to_share )
        share = Share.find(share_id)
        bitly = Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key])
        url = bitly.shorten(url_to_share)
        share.link_to_share = url.short_url
        share.deliver
      end

    end
    
  end
end
