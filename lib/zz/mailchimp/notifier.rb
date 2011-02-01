module ZZ
  module MailChimp
    class Notifier

      class << self
        include ActionDispatch::Routing::UrlFor
        include Rails.application.routes.url_helpers
        default_url_options[:host] = Server::Application.config.application_host
        
        def contributors_added(contributor_id)
          contributor = Contributor.find( contributor_id )
          user = contributor.album.user
          album = contributor.album

          merge_vars ={ :FNAME     => user.first_name,
                        :LNAME     => user.last_name,
                        :A_NAME    => album.name,
                        :A_URL     => album_url( album ),
                        :A_PICON   => album.picon_url,
                        :A_EMAIL   => album.short_email }
          ZZ::MailChimp::Message.new('contributors_added', contributor.email, merge_vars)
        end


        def upload_batch_finished( batch_id )
          batch = UploadBatch.find( batch_id )
          merge_vars ={ :F_NAME    => batch.user.first_name,
                        :L_NAME    => batch.user.last_name,
                        :A_NAME    => batch.album.name,
                        :A_URL     => album_url( batch.album),
                        :A_PICON   => batch.album.picon_url,
                        :A_EMAIL   => batch.album.short_email }
          ZZ::MailChimp::Message.new('upload_batch_finished', batch.user.email, merge_vars)
        end

        def album_shared_with_you(from_user_id,to_address,album_id, message)
          from_user = User.find(from_user_id)
          album = Album.find(album_id)
          merge_vars ={ :FROM_NAME => from_user.name,
                        :MESSAGE   => message,
                        :A_PICON   => album.picon_url,
                        :A_URL     => album_url( album),
                        :A_NAME    => album.name }
          ZZ::MailChimp::Message.new('album_shared_with_you', to_address, merge_vars)
        end

        def you_are_being_followed( follower_id, followed_id)
          follower = User.find( follower_id )
          followed = User.find( followed_id )
          raise Error 'Mail Message Not implemented yet. See ZZ::MailChimp::Notifier'
        end

        def activation_instructions(user_id)
          user = User.find(user_id)
          account_activation_url = activate_url(user.perishable_token)
          raise Error 'Mail Message Not implemented yet. See ZZ::MailChimp::Notifier'
        end

        def password_reset_instructions(user_id)
          user = User.find(user_id)
          merge_vars ={ :RESET_URL => edit_password_reset_url(user.perishable_token) }
          ZZ::MailChimp::Message.new('password_reset_instructions', user.email, merge_vars)
        end

        def welcome(user_id)
          # Signs the user up for the service_user email list with the send-welcome-email flag set
          # MailChimp sends the lists welcome email and adds the user to the list
          user = User.find(user_id)
          merge_vars ={ :FNAME    => user.first_name,
                        :LNAME    => user.last_name,
                        :UNAME    => user.username,
                        :U_URL    => user_url( user ),
                        :U_SIGNUP => Time.now().strftime('%Y-%m-%d') }
          ZZ::MailChimp::WelcomeMessage.new('welcome', user.email, merge_vars)
        end

        def test_email( to )
          merge_vars ={ :MSG => "This is the message body of the email integration test" }
          ZZ::MailChimp::Message.new('email-integration-testing', to , merge_vars)
        end
      end
    end
  end
end
