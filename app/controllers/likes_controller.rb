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

    LikeCounter.find_all_by_subject_id( wanted_subjects.keys ).each do |counter|
      subjects[ counter.subject_id ][:count]= counter.counter
    end

    if current_user
      Like.find_all_by_user_id_and_subject_id( current_user.id, wanted_subjects.keys).each  do | like |
        subjects[ like.subject_id ][:user]=true
      end
    end
    render :json =>subjects
  end

  def toggle
    if current_user && params[:subject_id] && params[:subject_type] && params[:user_likes_it]

        Like.toggle( current_user.id, params[:subject_id] , params[:subject_type] )
        #ZZ::Async::LikeClick.enqueue( current_user.id, params[:subject_id] , params[:subject_type] )
        if params[:user_likes_it]=='false' && current_user.preferences.asktopost_likes
            @subj_id   = params[:subject_id]
            @subj_type = params[:subject_type]
            @url, @message = Like.default_like_post_message(current_user, @subj_id, @subj_type )
            @is_facebook_linked = current_user.identity_for_facebook.credentials_valid?
            @is_twitter_linked  = current_user.identity_for_twitter.credentials_valid?
            render '_social_dialog.html.erb', :layout => false and return
        end
    end
    render :nothing => true
  end

  def post
    if current_user && params[:subject_id] && (params[:tweet] || params[:facebook] || params[:dothis])
      Like.post_with_preferences( current_user.id, params[:subject_id], params[:message], params[:tweet], params[:facebook], params[:dothis])
      #ZZ::Async::PostLike.enqueue( current_user.id, params['subject_id'], params['messge'], params['tweet'], params['facebook'], params['dothis'])
    end
    render :nothing => true
  end
end