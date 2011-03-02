module ZZ
  module Async
    class PostLike < Base
        @queue = :like

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.enqueue( current_user_id, subject_id, message, tweet, facebook, dothis )
          super( current_user_id, subject_id, message, tweet, facebook, dothis  )
        end

        def self.perform( current_user_id, subject_id, message, tweet, facebook, dothis  )
          Like.post_with_preferences( current_user_id, subject_id, message, tweet, facebook, dothis)
        end
    end
  end
end