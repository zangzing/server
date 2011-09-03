module ZZ
  module Mailer
    extend ActiveSupport::Concern

    included do
      ActionMailer::Base.logger = Rails.logger
      
      default :charset => "utf-8"
      if Rails.env == 'production'
        default :from => '"ZangZing Communications" <do-not-reply@zangzing.com>'
      else
        default :from => '"ZangZing '+Rails.env.capitalize+' Environment" <do-not-reply@zangzing.com>'
      end
    end

    #No class methods to add so no module ClassMethods

    module InstanceMethods
      private

      # This the the method that puts together the message using the class vars set in
      # the message environment
      #
      #
      # * <tt>template_name</tt> - The name of the production template you want to use. It
      #   will not be used if template_id is present
      # * <tt>template_id </tt> - The id of the specific template you want to use. Used for testing templates that are not
      #   in production yet.
      # * <tt>recipient</tt> - The recipient for the message, it maybe a User in which case we call
      #   recipient.formatted_email or a string with the email address
      # * <tt>event_data_hash</tt> - A hash of information that will be sent with to ZZA as xdata
      def create_message( template_name, template_id=nil, recipient=nil, zza_xdata=nil )

        # Load the appropriate template either the production version or the given id (for testing)
        if template_id
          @template  = EmailTemplate.find( template_id )
        else
          @template = Email.find_by_name!( template_name ).production_template
        end

        #check subscription preferences
        Subscriptions.wants_email!( recipient, @template.email )

        #Process recipient ( decide if it is an address or a user, build address and clean the double bytes)
        if recipient.is_a?(User)
          encoded_name = Mail::Encodings::decode_encode( recipient.name, :encode )
          @to_address  = Mail::Address.new("\"#{encoded_name}\" <#{recipient.email}>")
        else
          @to_address = Mail::Address.new( recipient.to_slug.to_ascii.to_s )
        end

        # Add unsubscribe links and headers see http://www.list-unsubscribe.com/
        @unsubscribe_url   = unsubscribe_url(  @unsubscribe_token = Subscriptions.unsubscribe_token( recipient ) )
        @unsubscribe_email = Mail::Address.new( "#{@unsubscribe_token}@unsubscribe.#{Server::Application.config.album_email_host}" ).address
        headers @template.sendgrid_category_header     #set sendgrid category header
        headers['X-ZZSubscription-Id'] = @unsubscribe_token
        headers['List-Unsubscribe'] = "<mailto:#{@unsubscribe_email}>,<#{@unsubscribe_url}>,"

        #send zza event
        ZZA.new.track_event("#{template.category}.send", zza_xdata )

        #add log entry
        log_entry =  "EMAIL_SENT === #{template_name} to #{@to_address}"
        log_entry += " Triggered by  #{@user.username} (#{@user.id})" if @user
        log_entry += " About album #{@album.name} (#{@album.id})" if @album
        log_entry += " UploadBatch (#{@batch.id})  with #{@batch.photos.count} photos" if @batch
        logger.info log_entry

        #create message
        mail( :to       => @to_address.format,
              :from     => @template.formatted_from,
              :reply_to => ERB.new( @template.formatted_reply_to).result,
              :subject  => ERB.new( @template.subject).result
        ) do |format|
          format.text { render :inline => @template.text_content }
          format.html { render :inline => @template.html_content }
        end
      end

      def destination_link( recipient, destination_url )
        if recipient.is_a?(User)
          "#{signin_url}?return_to=#{destination_url}&email=#{recipient.username}"
        else
          "#{join_url}?return_to=#{destination_url}&email=#{recipient}"
        end
      end
    end
  end
end