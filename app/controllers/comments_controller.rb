class CommentsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

#  before_filter :require_user
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


  def create
    commentable = Commentable.find_or_create_by_photo_id(params[:photo_id])
    comment = Comment.new
    comment.text = sanitize(params[:comment][:text])
    comment.user = current_user
    commentable.comments << comment
    comment.save!

    zza.track_event("photo.comment.create", {:photo_id => params[:photo_id]})


    if(params[:post_to_facebook])
      comment.post_to_facebook
      zza.track_event("photo.comment.post.facebook", {:photo_id => params[:photo_id]})
    end


    if(params[:post_to_twitter])
      comment.post_to_twitter
      zza.track_event("photo.comment.post.twitter", {:photo_id => params[:photo_id]})
    end

    comment.send_notification_emails

    render :json => JSON.fast_generate(comment.as_json), :status => 200 and return

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
      @album = Album.find(params[:album_id])
    end
  end

end

