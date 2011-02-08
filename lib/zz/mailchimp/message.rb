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
        ZZ::MailChimp.load_setup() if $campaigns.nil?
   
        subscribed = false
        sent = false
        unsubscribed = false
        begin

          begin
            puts "In Deliver Subscribe"
            # subscribe( list_id, to_email, merge_bars, email_type(html or text), use_double_optin,update_existing,replace_interests,send_welcome  )
            subscribed = Chimp.list_subscribe(  $campaigns[@name]['list_id'], @to_email, @merge_vars, 'html', false, true, false, false)
          rescue Hominid::APIError => e
            if e.message.match( /^\<214\>.*/) #<214> XXXX@zangzing.com is already subscribed to list XXXX
              #subscribe failed, try unsubscribe with delete?=true and subscribe again
              Chimp.list_unsubscribe(  $campaigns[@name]['list_id'], @to_email, 'false','false','false')
              subscribed = Chimp.list_subscribe(  $campaigns[@name]['list_id'], @to_email, @merge_vars, 'html', false, false, false,false)
            else
              raise e
            end
          end

          if subscribed
            puts "In Deliver Sending campaign"
            sent = Chimp.campaign_send_now( $campaigns[@name]['id'] )
          end

          if subscribed && sent
            puts "In Deliver Unsubscribed"
            # unsubscribe( list_id, email_to_unsubscribe, delete?, send_goodbye?, notify_admin? )
            unsubscribed = Chimp.list_unsubscribe(  $campaigns[@name]['list_id'], @to_email, 'false','false','false')
          end
        rescue Hominid::APIError => e
          raise Error, "Message.delivery error: "+e.message
        end

        puts "In Deliver Done"
        subscribed && sent && unsubscribed # return true if all succeeded
      end
    end

    class WelcomeMessage < Message
      @@zangzing_users_list = nil
      def deliver
        if @@zangzing_users_list.nil?
          @@zangzing_users_list = Chimp.find_list_by_name( MAILCHIMP_API_KEYS[:zangzing_users_list] )
          if @@zangzing_users_list .nil? 
            raise Error, "WelcomeMessage.delivery error: users list: <"+
                MAILCHIMP_API_KEYS[:zangzing_users_list]+
                "> Not Found. Unable to sign up user to list and deliver welcome message"
          end
        end

        @subscribed = false
        begin
          # Subscribe to zangzing_users list with send_welcome email flag set to true
          # MailChimp will subscribe the user and send the lists Welcome Email
          @subscribed = Chimp.list_subscribe(  @@zangzing_users_list['id'],
                                               @to_email,    #to_email
                                               @merge_vars,  #merge_vars
                                               'html',       #email type
                                               false,        #double opt_in
                                               false,        #update existing
                                               false,        #replace interests
                                               true)         #send welcome

        rescue Hominid::APIError => e
          raise Error, "Message.delivery error: "+e.message
        end

        @subscribed  # return true if subscribe succeeded
      end
    end
  end
end