module ZZ
  module Async
    class Base
      
      # This method can be overrriden in a subclass to perform argument validation and then
      # called from the subclass. The idea is that this should be the only place to call
      # Resque enqueue
      private
      def self.enqueue( *args )
        Resque.enqueue( self, *args)
      end
    end
  end

  #Delayed::IoBoundJob.enqueue(GeneralImportRequest.new(photo.id, p[:source]))
  #Delayed::IoBoundJob.enqueue(KodakImportRequest.new(photo.id, photo_url, connector.auth_token))
  #Delayed::CpuBoundJob.enqueue Delayed::PerformableMethod.new(self, :update_picon, [] )
  #Mailer =>Delayed::IoBoundJob.enqueue Delayed::PerformableMethod.new(Notifier, :deliver, [msg] )
  #Delayed::CpuBoundJob.enqueue(S3UploadRequest.new(self.id))
  #Delayed::IoBoundJob.enqueue LinkShareRequest.new(self.id, self.link_to_share)
  # TODO implement this call with resque-scheduler if needed:
  #Upload Batch Cloes nb is new batch   Delayed::IoBoundJob.enqueue(  Delayed::PerformableMethod.new( nb, :close, {} ) , 0 ,  30.minutes.from_now  );

end