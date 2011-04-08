class LikesController < ApplicationController
  before_filter :require_user_json, :only => [:create, :post]
  before_filter :require_user, :only => [:like]

  def index
    wanted_subjects = params['wanted_subjects']
    render :nothing => true, :status =>400 and return if wanted_subjects.nil?

    subjects =  Hash.new()
    render :json =>subjects, :status => :ok and return if wanted_subjects.length <=0
    wanted_subjects.keys.each do |wanted_id|
      type = case wanted_subjects[wanted_id].downcase
               when 'photo' then  Like::PHOTO
               when 'album' then Like::ALBUM
               when 'user'  then Like::USER
             end
      subjects[wanted_id] = { :count => 0, :user => false, :type => type }
    end

    counters = LikeCounter.find_all_by_subject_id( wanted_subjects.keys )
    # filter down the set based on the results of the counter lookup - if items
    # were missing from the counter table no reason to pass them on to the likes table
    wanted_subject_ids = []
    if( counters && counters.length > 0)
      counters.each do |counter|
        wanted_subject_id = counter.subject_id
        wanted_subject_ids << wanted_subject_id
        subjects[ wanted_subject_id.to_s ][:count]= counter.counter
      end
    end

    # this filter may be a subset (down to zero possibly) of the initial
    # set since we use the results of the LikeCounter lookup to tell us
    # which subject_ids matched.  For ones that don't no reason to pass them on
    if !wanted_subject_ids.empty? && current_user
      likes = Like.find_all_by_user_id_and_subject_id( current_user.id, wanted_subject_ids)
      if( likes && likes.length > 0)
        likes.each  do | like |
          subjects[ like.subject_id.to_s ][:user]=true
        end
      end
    end
    render :json =>JSON.fast_generate(subjects)
  end

  def like
    if params[:user_id]
      @subject_id   = params[:user_id]
      @subject_type = 'user'
      @redirect_url = user_url( User.find(@subject_id) )
    elsif params[:album_id]
      @subject_id   = params[:album_id]
      @subject_type = 'album'
      @redirect_url = album_url( Album.find(@subject_id) )
    elsif params[:photo_id]
      @subject_id   = params[:photo_id]
      @subject_type = 'photo'
      @redirect_url = photo_pretty_url( Photo.find(@subject_id) )
    else
      #params are not complete
      render :text => "subject_id and/or subject_type not in params, unalbe to process", status => 400 and return
    end
    ZZ::Async::ProcessLike.enqueue( 'add', current_user.id, @subject_id , @subject_type )
    redirect_to @redirect_url
  end


  def create
    if params[:subject_id] && params[:subject_type]
      ZZ::Async::ProcessLike.enqueue( 'add', current_user.id, params[:subject_id] , params[:subject_type] )
      if current_user.preferences.asktopost_likes
        # The user has not set a preference about being asket to post his/her likes,
        # create the like and  show the likes social dialog
        # If the user does not want to be asked about posting likes, just create it and it will be posted according
        # to user_preferences
        @subject_id   = params[:subject_id]
        @subject_type = params[:subject_type]
        @message = Like.default_like_post_message(@subject_id, @subject_type )
        @is_facebook_linked = current_user.identity_for_facebook.credentials_valid?
        @is_twitter_linked  = current_user.identity_for_twitter.credentials_valid?
        render '_social_dialog.html.erb', :layout => false and return
      end
    end
    render :nothing => true
  end

  def post
    if current_user && params[:subject_id] && params[:subject_type] && (params[:tweet] || params[:facebook] || params[:dothis])
      ZZ::Async::ProcessLike.enqueue( 'post',current_user.id, params[:subject_id], params[:subject_type],params[:message], params[:tweet], params[:facebook], params[:dothis])
    end
    render :nothing => true
  end

  def destroy
    if current_user && params[:subject_id]
      #Like.remove( current_user.id, params[:subject_id])
      ZZ::Async::ProcessLike.enqueue( 'remove', current_user.id, params[:subject_id])
    end
    render :nothing => true
  end

end