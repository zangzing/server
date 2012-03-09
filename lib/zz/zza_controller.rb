module ZZ
  module ZZAController
    extend ActiveSupport::Concern

    included do
     # give the zza worker a chance to restart if we are running
      # as a forked process because it will have been killed in that
      # case.  Later when we move to Amazon we can control the Unicorn
      # config file directly and do it only once from within there

      ZZ::ZZA.after_fork_check
    end

    #No class methods to add so no module ClassMethods

    module InstanceMethods

      def send_zza_event_from_client (event)
        events = session[:send_zza_events_from_client] || []
        events << event
        session[:send_zza_events_from_client] = events
      end

      # returns the user context in zza compatible form
      # [user_id, user_type, ip]
      def zza_user_context
        if current_user
          user_id = current_user.id
          user_type = 1
          zzv_id = current_user.zzv_id
        else
          user_id = cookies['_zzv_id']
          user_type = 2
          zzv_id = user_id
        end
        [user_id, user_type, zzv_id, request.remote_ip]
      end

      # Return a correctly initialized reference to zza tracking service
      def zza
        return @zza if @zza
        @zza = ZZ::ZZA.new
        @zza.user, @zza.user_type, @zza.zzv_id = zza_user_context
        @zza
      end
    end
  end
end