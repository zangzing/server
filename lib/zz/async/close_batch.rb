module ZZ
  module Async

    class CloseBatch < Base
      @queue = :io_bound
      
      def self.enqueue( batch_id )
        super( batch_id )
      end

      def self.perform( batch_id )
        batch = UploadBatch.find( batch_id )
        batch.close
      end

    end
  end
end