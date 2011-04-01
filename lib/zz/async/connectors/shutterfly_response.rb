module ZZ
  module Async
    module Connectors
      
      class ShutterflyResponse < Base
        @queue = :io_bound

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.enqueue(response_id, identity_id, params )
          super(response_id, identity_id, params )
        end

        def self.perform(response_id, identity_id, params )
          SystemTimer.timeout_after(ZangZingConfig.config[:async_connector_timeout]) do
            params.symbolize_keys!
            user_identity = Identity.find(identity_id)
            api = Connector::ShutterflyController.api_from_identity(user_identity)
            json = case params[:method]
              when 'shutterfly_folders#index' then Connector::ShutterflyFoldersController.folder_list(api)
              when 'shutterfly_folders#import' then Connector::ShutterflyFoldersController.import_folder(api, params, user_identity)
              when 'shutterfly_photos#index' then Connector::ShutterflyPhotosController.photos_list(api, params)
              when 'shutterfly_photos#import' then Connector::ShutterflyPhotosController.import_photo(api, params, user_identity)
            end
            AsyncResponse.store_response(response_id, json)
          end
        end

        def self.on_failure_notify_photo(e, response_id, identity_id, params )
          begin
            SystemTimer.timeout_after(ZangZingConfig.config[:async_connector_timeout]) do
            end
          rescue Exception => ex
            # eat any exception in the error handler
          end
        end
      end

    end
  end
end