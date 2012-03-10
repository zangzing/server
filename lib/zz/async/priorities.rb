module ZZ
  module Async

    # this class gives us a common class to return the
    # given photo priorities for various named operations
    #
    # Keep the list of methods in priority order for ease
    # of viewing
    #
    class Priorities
      def self.profile_photo
        100
      end

      def self.batch_sweep
        90
      end

      def self.photo_edit
        90
      end

      def self.mailer_high
        80
      end

      def self.connector_worker
        80
      end

      def self.single_photo
        80
      end

      def self.iphone_single
        70
      end

      def self.iphone_batch
        70
      end

      def self.facebook
        60
      end

      def self.twitter
        60
      end

      def self.like
        60
      end

      def self.mailer
        50
      end

      # batch of web ui uploaded photos
      def self.web_batch
        50
      end

      def self.deliver_share
        50
      end

      def self.streaming_album_update
        50
      end

      def self.ezp_simulator
        50
      end

      def self.ezp_submit_order
        50
      end

      def self.mailing_list_sync
        50
      end

      def self.single_album_import
        40
      end

      def self.import_all
        30
      end

      def self.mailer_low
        20
      end

      def self.test
        20
      end

      def self.cleanup
        20
      end

      def self.background_resize
        10
      end

      # given a priority level and a queue type return the name of the
      # queue to use
      def self.queue_name(type, priority)
        priority ||= 50  # if priority not passed default to middle priority
        "#{type}_#{priority}".to_sym
      end

      # map to a local queue - we only have a small set so
      # pick appropriate one based on priority
      def self.local_queue_name(type, priority)
        priority ||= 50  # if priority not passed default to middle priority

        if priority >= 90
          priority = 100
        else
          priority = 50
        end
        "#{type}_#{Server::Application.config.deploy_environment.this_host_name}_#{priority}".to_sym
      end
    end

  end
end
