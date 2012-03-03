module ZZ
  module Async

    class DeleteUser < Base
        @queue = :io_bound

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.enqueue( user_id )
          super( user_id)
        end

        def self.perform( user_id )
          user = User.find(user_id)
          user.destroy
        end
    end
  end
end