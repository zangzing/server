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
        70
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

      def self.default_priority
        50
      end

      def self.mailer
        50
      end

      # batch of web ui uploaded photos
      def self.web_batch
        50
      end

      def self.import_single_photo
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

      def self.import_single_album
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
        priority ||= default_priority  # if priority not passed use default
        "#{type}_#{priority_format(priority)}".to_sym
      end

      def self.io_queue_name(priority)
        queue_name('io', priority)
      end

      def self.cpu_queue_name(priority)
        queue_name('cpu', priority)
      end

      # return priority as formatted string
      # with leading 0's
      def self.priority_format(priority)
        "%03d" % priority
      end

      # map to a local queue - we only have a small set so
      # pick appropriate one based on priority
      def self.io_local_queue_name(priority)
        priority ||= default_priority  # if priority not passed use default

        if priority >= 90
          priority = 100
        elsif priority >=50
          priority = 50
        else
          priority = 30
        end
        "#io_local_#{Server::Application.config.deploy_environment.this_host_name}_#{priority_format(priority)}".to_sym
      end
    end

  end
end
