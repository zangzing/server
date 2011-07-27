class CommentsController < ApplicationController
  before_filter :require_user
  before_filter :require_album
  before_filter :require_album_viewer_role
  
  def metadata
    commentable = Commentable.find_or_create_by_photo_id(@photo.id)
    render :json=>JSON.fast_generate(commentable.metadata_as_hash)
  end


  def index
    commentable = Commentable.find_or_create_by_photo_id(@photo.id)
    render :json=>JSON.fast_generate(commentable.comments_as_hash)
  end


  def create
    commentable = Commentable.find_or_create_by_photo_id(@photo.id)
    comment = Comment.new(params[:comment])
    comment.user = current_user
    commentable.comments << comment
    comment.save!
  end

  def destroy
    comment = Comment.find(params[:comment_id])

    if(current_user && current_user.id == comment.user_id)
      comment.destroy
    else
      render :nothing => true, :status => 401
    end
  end

private

  def require_album
    @photo = Photo.find(params[:photo_id])
    @album = @photo.album
  end

end

