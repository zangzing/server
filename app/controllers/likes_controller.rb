class LikesController < ApplicationController
  before_filter :require_user_json, :only => [:create, :post]
  before_filter :require_user, :only => [:like]

  def index
    wanted_subjects = params['wanted_subjects']
    head :status =>400 and return if wanted_subjects.nil?

    subjects =  Hash.new()
    render :json =>subjects, :status => :ok and return if wanted_subjects.length <=0
    wanted_subjects.keys.each do |wanted_id|
      subjects[wanted_id] = { :count => 0, :user => false, :type => Like.clean_type( wanted_subjects[wanted_id].downcase ) }
    end

    wanted_values = subjects.map{ |key, value| "(#{key.to_i}, '#{value[:type]}')" }.join(',')
    counters = LikeCounter.where("(subject_id, subject_type) IN ( #{wanted_values} )").all
    # filter down the set based on the results of the counter lookup - if items
    # were missing from the counter table no reason to pass them on to the likes table
    wanted_subject_ids = []

    if current_user
      @current_user_id = current_user.id
    else
      @current_user_id = nil
    end
    
    if( counters && counters.count > 0)
      counters.each do |counter|
        if @current_user_id
          wanted_subject_ids << "(#{@current_user_id}, #{counter.subject_id},'#{counter.subject_type}')"
        end
        subjects[ counter.subject_id.to_s ][:count]= counter.counter
      end
    end

    # this filter may be a subset (down to zero possibly) of the initial
    # set since we use the results of the LikeCounter lookup to tell us
    # which subject_ids matched.  For ones that don't no reason to pass them on
    if @current_user_id  && !wanted_subject_ids.empty?
      likes = Like.where("(user_id, subject_id, subject_type) IN ( #{wanted_subject_ids.join(',')} )" ).all
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
      @user = User.find( @subject_id )
      @redirect_url = user_pretty_url( @user  )
      @subject_id = @user.id
      redirect_to @redirect_url and return if @user == current_user
    elsif params[:album_id]
      @subject_id   = params[:album_id]
      @subject_type = 'album'
      @album = Album.find(@subject_id)
      @redirect_url = album_pretty_url( @album )
      @subject_id = @album.id

    elsif params[:photo_id]
      @subject_id   = params[:photo_id]
      @subject_type = 'photo'
      @photo        = Photo.find(@subject_id)
      @redirect_url = photo_pretty_url( @photo )
      @message = "like this photo by #{@photo.user.name}"
    else
      #params are not complete
      render :text => "subject_id and/or subject_type not in params, unalbe to process", status => 400 and return
    end
    #ZZ::Async::ProcessLike.enqueue( 'add', current_user.id, @subject_id , @subject_type )
    if Like.add( current_user.id, @subject_id, @subject_type )
      case @subject_type
        when 'user'  then  flash[:notice] = "You are now following  #{@user.name}"
        when 'album' then  flash[:notice] = "You now like #{@album.name} by #{@album.user.name}"
        when 'photo' then  flash[:notice] = "You now like this photo by #{@photo.user.name}"
      end
    else
      case @subject_type
        when 'user'  then  flash[:notice] = "You are already following  #{@user.name}"
        when 'album' then  flash[:notice] = "You already like #{@album.name} by #{@album.user.name}"
        when 'photo' then  flash[:notice] = "You already like this photo by #{@photo.user.name}"
      end
    end
    add_javascript_action( 'show_message_dialog',  {:message => flash[:notice]})
    redirect_to @redirect_url
  end


  def create
    if params[:subject_id] && params[:subject_type]
      ZZ::Async::ProcessLike.enqueue( 'add', current_user.id, params[:subject_id] , params[:subject_type] )
      #if current_user.preferences.asktopost_likes
      #  # The user has not set a preference about being asket to post his/her likes,
      #  # create the like and  show the likes social dialog
      #  # If the user does not want to be asked about posting likes, just create it and it will be posted according
      #  # to user_preferences
      #  @subject_id   = params[:subject_id]
      #  @subject_type = params[:subject_type]
      #  @message = Like.default_like_post_message(@subject_id, @subject_type )
      #  @is_facebook_linked = current_user.identity_for_facebook.credentials_valid?
      #  @is_twitter_linked  = current_user.identity_for_twitter.credentials_valid?
      #  render '_social_dialog.html.erb', :layout => false and return
      #end
    end
    render :nothing => true
  end

  #def post
  #  if current_user && params[:subject_id] && params[:subject_type] && (params[:tweet] || params[:facebook] || params[:dothis])
  #    ZZ::Async::ProcessLike.enqueue( 'post',current_user.id, params[:subject_id], params[:subject_type],params[:message], params[:tweet], params[:facebook], params[:dothis])
  #  end
  #  render :nothing => true
  #end

  def destroy
    if current_user && params[:subject_id] && params[:subject_type]
      ZZ::Async::ProcessLike.enqueue( 'remove', current_user.id, params[:subject_id], Like.clean_type( params[:subject_type] ))
    end
    render :nothing => true
  end

end