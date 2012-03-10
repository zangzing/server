module ZZ
  module Async

    class EZPSimulator < Base
      @queue = Priorities.queue_name('io', Priorities.ezp_simulator)

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      # using class_inheritable_accessor our sub classes can now utilize our defaults
      # normally you would have to define these in the subclasses these are used
      # by the retry plugin
      # This is just an example if we want to have a custom backoff strategy
      def self.backoff_strategy
       # default strategy timeouts, children should override for more specific policies
        @backoff_strategy ||= [5.seconds, 5.seconds, 5.seconds]
      end

      def self.enqueue( order_id, method_name, options = {} )
        super( order_id, method_name, options )
      end

      def self.enqueue_in( secs_from_now, order_id, method_name, options = {} )
        super( secs_from_now, @queue, order_id, method_name, options )
      end

      def self.perform( order_id, method_name, options )
        options.recursively_symbolize_keys!
        SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
          order = Order.find(order_id)
          self.send(method_name.to_sym, order, options)
        end
      end

      def self.handle_failure(exception, will_retry, order_id, method_name, options)
        if will_retry == false
          # not going to retry, we are done so notify order
          order = Order.find(order_id)
          order.ezp_submit_order_failed
        end
      end

      # return seconds randomly between min and max inclusive
      def self.random_seconds(min, max)
        ZangZingConfig.fast_ezp_simulator? ? 1 : min + rand(max - min + 1)
      end

      # specify an integer from 0-100 which
      # indicates the odds of returning true
      def self.random_chance(odds)
        pick = rand(100)
        pick < odds
      end

      def self.notification_handler
        @@notification_handler ||= EzPrintController.new
      end

      def self.empty_details
        @@empty_details ||= {}
      end

      # the various simulator methods, take appropriate action and queue up the next stage

      # kick start things by queueing up the first simulated notification
      def self.simulate_order(order)
        # create a simulated ezp reference id and save in order
        order.ezp_reference_id = UUIDTools::UUID.random_create.to_s
        order.save!

        # now queue up the next stage which is order acceptance
        enqueue_in(random_seconds(10, 60), order.id, :accepted)
      end

      def self.accepted(order, options)
        notification_handler.accepted(order, empty_details)
        # now queue up the next stage which is in production
        enqueue_in(random_seconds(10, 60), order.id, :in_production)
      end

      def self.in_production(order, options)
        notification_handler.in_production(order, empty_details)
        # now queue up the next stage which is in production
        if random_chance(3)
          # cancel the order from the ezp side
          enqueue_in(random_seconds(30, 90), order.id, :canceled)
        else
          # continue as normal
          enqueue_in(random_seconds(30, 60), order.id, :shipment)
        end
      end

      def self.shipment(order, options)
        # randomly break apart the shipment - some will
        # be treated as whole, others will come in parts
        all_line_items = order.line_items
        # just take the ones that have not been marked as shipped
        line_items = []
        all_line_items.each do |item|
          line_items << item if item.shipment_id.nil?
        end
        items_remaining = line_items.count
        if items_remaining == 0
          # nothing left to ship, move to order complete state
          enqueue_in(random_seconds(10, 60), order.id, :complete)
          return
        end

        items =[]
        if random_chance(70)
          # split the order
          items_remaining -= 1
          line_item = line_items.first
          item = {
              :Id => line_item.id
          }
          items << item
        else
          # treat remaining items together
          line_items.each do |line_item|
            item = {
                :Id => line_item.id
            }
            items << item
          end
          items_remaining = 0
        end

        carriers = ['USPS', 'UPS', 'FEDEX']
        carrier = carriers[rand(carriers.count)]
        details = {
            :TrackingNumber => carrier == 'USPS' ? '' : "#{carrier}-#{rand(999999999)}-#{rand(999999999)}",
            :Carrier        => carrier,
            :Item           => items
        }

        notification_handler.shipment(order, details)

        if items_remaining > 0
          # go again since not all shipped yet
          enqueue_in(random_seconds(30, 60), order.id, :shipment)
        else
          # move on to the next phase which is complete
          enqueue_in(random_seconds(10, 60), order.id, :complete)
        end
      end

      # cancel the order
      def self.canceled(order, options)
        notification_handler.canceled(order, empty_details)
      end

      # last step in the process
      def self.complete(order, options)
        notification_handler.complete(order, empty_details)
      end

    end
  end
end
