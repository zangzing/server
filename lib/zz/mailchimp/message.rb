module ZZ
  module MailChimp
    class Message
      @name = nil
      @to_email = nil
      @merge_vars = nil

      def initialize( name, to_email, merge_vars )
        @name = name
        @to_email = to_email
        @merge_vars = merge_vars
      end

      def deliver
        raise Error, "Message.delivery error: Campaigns not loaded, did load_setup fail. Unable to deliver #{@name} message" if $campaigns.nil?

        @subscribed = false
        @sent = false
        @unsubscribed = false

        begin
          @subscribed = Chimp.list_subscribe(  $campaigns[@name]['list_id'],
                                               @to_email,    #to_email
                                               @merge_vars,  #merge_vars
                                               'html',       #email type
                                               false)        #double opt_in

          if @subscribed
            @sent = Chimp.campaign_send_now( $campaigns[@name]['id'] )
          end


          if @subscribed
            @unsubscribed = Chimp.list_unsubscribe(  $campaigns[@name]['list_id'], #list id
                                                     @to_email, #email to delete
                                                     'true',                  #delete?
                                                     'false',                 #send goodbye?
                                                     'false')                 #notify admin
          end
        rescue Hominid::APIError => e
          raise Error, "Message.delivery error: "+e.message
        end

        @subscribed && @sent #&& @unsubscribed # return true if all succeeded
      end
    end
  end
end