class CommentsController < ApplicationController
  before_filter :require_user
  before_filter :require_album, :except => :destroy
  before_filter :require_album_viewer_role, :except => :destroy
  



  # returns comment meta-data for each photo in album
  def album_photos_metadata
    render :json=>JSON.fast_generate(Commentable.album_photos_metadata_as_json(params[:album_id]))
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
  end

  def destroy
    comment = Comment.find(params[:comment_id])

    photo = Photo.find(comment.commentable.subject_id)

    # only comment owner, album owner, and photo owner
    # can delete comments
    if current_user && [comment.user_id, photo.album.user.id, photo.user.id].include?(current_user.id)
      comment.destroy
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 401
    end
  end

private


  def require_album
    if params[:photo_id]
      @photo = Photo.find(params[:photo_id])
      @album = @photo.album
    else
      @album = Album.find(params[:album_id])
    end
  end

end

