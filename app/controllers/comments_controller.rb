class CommentsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_filter :require_user, :only => [:finish_create, :destroy]
  before_filter :require_album, :except => [:destroy, :metadata_for_subjects]
  before_filter :require_album_viewer_role, :except => [:destroy, :metadata_for_subjects]
  



  # returns comment meta-data for each photo in album
  def metadata_for_album_photos
    commentables = Commentable.find_for_album_photos(params[:album_id])
    render_commentables(commentables)
  end


  def metadata_for_subjects
    commentables = Commentable.find_by_subjects(params[:subjects])
    render_commentables(commentables)
  end



  # returns comment meta-data and comments for photo
  def index
    photo = Photo.find(params[:photo_id])


    json = {
        :commentable => Commentable.photo_comments_as_json(params[:photo_id]),
        :current_user => {
            :can_delete_comments => current_user && (current_user == photo.user || current_user == photo.album.user),
        }
    }

    render :json=>JSON.fast_generate(json)
  end

   

  # guest commenter is redirected here after signin
  # releavent params have all been copied to session (see below in #create)
  def finish_create
    create_comment(session[:comment][:text])
    set_show_comments_cookie
    redirect_to photo_pretty_url(Photo.find(params[:photo_id]))
  end


  # create comment if there is user, or capture params in session
  # and redirect to signin (and then to #finish_create)
  def create
    if current_user

      comment = create_comment(params[:comment][:text])

      if(params[:post_to_facebook] == "true")
        comment.post_to_facebook
        zza.track_event("photo.comment.post.facebook", {:photo_id => params[:photo_id]})
      end


      if(params[:post_to_twitter] == "true")
        comment.post_to_twitter
        zza.track_event("photo.comment.post.twitter", {:photo_id => params[:photo_id]})
      end


      render :json => JSON.fast_generate(comment.as_json), :status => 200 and return

    else
      session[:comment] = params[:comment]
      flash[:error] = 'You must join or sign in to post comments'
      head :status => 401 # javascript looks for this status code and does a redirect in javascript
    end  



  end



  def destroy
    comment = Comment.find(params[:comment_id])


    if comment.commentable.subject_type == Commentable::SUBJECT_TYPE_PHOTO
      photo = Photo.find(comment.commentable.subject_id)

      # only comment owner, album owner, and photo owner
      # can delete comments
      if current_user && [comment.user_id, photo.album.user.id, photo.user.id].include?(current_user.id)
        comment.destroy
        render :nothing => true, :status => 200 and return
      end
    end

    render :nothing => true, :status => 401 and return

  end

private

  def create_comment(text)
    commentable = Commentable.find_or_create_by_photo_id(params[:photo_id])
    comment = Comment.new
    comment.text = sanitize(text)
    comment.user = current_user
    commentable.comments << comment
    comment.save!

    comment.send_notification_emails

    zza.track_event("photo.comment.create", {:photo_id => params[:photo_id]})

    return comment
  end

  def render_commentables(commentables)
    results = []

    commentables.each do |commentable|
      results << commentable.metadata_as_json
    end

    render :json=>JSON.fast_generate(results)
    
  end

  def require_album
    if params[:photo_id]
      @photo = Photo.find(params[:photo_id])
      @album = @photo.album
    else
      @album = Album.safe_find(params[:album_id])
    end
  end

end

