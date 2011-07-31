class CommentsController < ApplicationController
  before_filter :require_user
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
    render :json=>JSON.fast_generate(Commentable.photo_comments_as_json(params[:photo_id]))
  end


  def create
    commentable = Commentable.find_or_create_by_photo_id(params[:photo_id])
    comment = Comment.new(params[:comment])
    comment.user = current_user
    commentable.comments << comment
    comment.save!
    render :json => JSON.fast_generate(comment.attributes), :status => 200 and return

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

