class LikesController < ApplicationController
  before_filter :require_user_json, :only => [:toggle, :post]

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
    if( counters && counters.length > 0)
      counters.each do |counter|
        subjects[ counter.subject_id.to_s ][:count]= counter.counter
      end
    end

    if current_user
      likes = Like.find_all_by_user_id_and_subject_id( current_user.id, wanted_subjects.keys)
      if( likes && likes.length > 0)
        likes.each  do | like |
          subjects[ like.subject_id.to_s ][:user]=true
        end
      end
    end
    render :json =>subjects
  end

  def create
    if current_user && params[:subject_id] && params[:subject_type] 

        #Like.add( current_user.id, params[:subject_id] , params[:subject_type] )
        ZZ::Async::Like.enqueue( 'add', current_user.id, params[:subject_id] , params[:subject_type] )
        if current_user.preferences.asktopost_likes
          begin
            @subj_id   = params[:subject_id]
            @subj_type = params[:subject_type]
            @url, @message = Like.default_like_post_message(current_user, @subj_id, @subj_type )
            @is_facebook_linked = current_user.identity_for_facebook.credentials_valid?
            @is_twitter_linked  = current_user.identity_for_twitter.credentials_valid?
            render '_social_dialog.html.erb', :layout => false and return
          rescue ActiveRecord::RecordNotFound
            #If the record was not found, lets not tweet about it
          end
        end
    end
    render :nothing => true
  end

  def destroy
      if current_user && params[:subject_id]
          #Like.remove( current_user.id, params[:subject_id])
          ZZ::Async::Like.enqueue( 'remove', current_user.id, params[:subject_id])
      end
      render :nothing => true
  end

  def post
    if current_user && params[:subject_id] && (params[:tweet] || params[:facebook] || params[:dothis])
      #Like.post_with_preferences( current_user.id, params[:subject_id], params[:message], params[:tweet], params[:facebook], params[:dothis])
      ZZ::Async::Like.enqueue( 'post_with_preferences',current_user.id, params[:subject_id], params[:message], params[:tweet], params[:facebook], params[:dothis])
    end
    render :nothing => true
  end
end