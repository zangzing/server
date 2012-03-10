module ZZ
  module Async

    class TestNoop < Base
      @queue = Priorities.queue_name('io', Priorities.test)

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      def self.enqueue(test_id, command, iteration)
        super(test_id, command, iteration)
      end

      def self.perform(test_id, command, iteration)
#        puts "#{command} - #{iteration}"
        case command
          when 'start'
            test = BenchTest::ResqueNoOp.find(test_id)
            test.start = DateTime.now
            test.result_message = "Test started."
            test.save!
          when 'stop'
            test = BenchTest::ResqueNoOp.find(test_id)
            test.stop = DateTime.now
            test.result_message = "Test complete."
            test.save!            
        end
      end

    end

  end
end
