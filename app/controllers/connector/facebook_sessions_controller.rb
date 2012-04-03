class Connector::FacebookSessionsController < Connector::FacebookController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    auth_url = HyperGraph.authorize_url(FACEBOOK_API_KEYS[:app_id],
                                        create_facebook_session_url(:host => Server::Application.config.application_host),
                                        :scope => 'user_photos,user_photo_video_tags,friends_photo_video_tags,friends_photos,publish_stream,offline_access,read_friendlists,email',
                                        :display => 'popup')
    redirect_to auth_url
  end

  def create
    token = nil
    if params[:error] #If user denied access or another crap happened
       @error = params[:error_description]
    else  
      SystemTimer.timeout_after(http_timeout) do
        token = HyperGraph.get_access_token(FACEBOOK_API_KEYS[:app_id], FACEBOOK_API_KEYS[:app_secret], create_facebook_session_url(:host => Server::Application.config.application_host), params[:code])
      end
      @error = 'Access token is not supplied from Facebook' unless token
      service_identity.update_attribute(:credentials, token)
    end
    render 'connector/sessions/create'
  end

  def destroy
    service_identity.credentials = nil
    service_identity.update_attribute(:credentials, nil)
    render 'connector/sessions/destroy'
  end

end


# other permissions we might consider
#user_about_me
#user_activities
#user_birthday
#user_events
#user_groups
#user_interests
#user_likes
#user_location
#user_photo_video_tags
#user_photos
#user_relationships
#user_videos
#user_website
#user_work_history
#email
#read_friendlists
#read_stream
#user_checkins
#user_address
#user_mobile_phone
#friends_about_me
#friends_activities
#friends_birthday
#friends_events
#friends_groups
#friends_interests
#friends_likes
#friends_location
#friends_photo_video_tags
#friends_photos
#friends_relationships
#friends_videos
#friends_website
#friends_work_history
#manage_friendlists
#friends_checkins

