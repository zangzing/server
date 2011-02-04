module ZZ
  module Async

    class LikeClick < Base
        @queue = :like

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.enqueue( current_user_id, subject_id, subject_type )
          super( current_user_id, subject_id, subject_type )
        end

        def self.perform( current_user_id, subject_id, subject_type )
          Like.toggle( current_user_id, subject_id, subject_type )
        end

    end
  end
end