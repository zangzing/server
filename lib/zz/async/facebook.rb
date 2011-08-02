module ZZ
  module Async

    class Facebook < Base
      @queue = :io_bound

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end




      def self.enqueue_facebook_post(user_id, message, link)
        super(user_id, message, link)
      end

      def self.perform( user_id, message, link )
        user = User.find(user_id)

        user.identity_for_facebook.post()

      end
    end
  end
end
