module ZZ
  module Async

    class CloseBatch < Base
      @queue = :io_bound
      
      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

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