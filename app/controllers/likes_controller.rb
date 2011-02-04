class LikesController < ApplicationController
  respond_to :json
  before_filter :require_user, :only => :index

  def index
    likes  = Like.find_all_by_user_id( current_user.id )
    likes_hash = Hash.new()
    likes.each{ |l|  likes_hash[l.subject_id] = 'liked'}
    respond_with( likes_hash )
  end

  def toggle

    if current_user
      current_user_id = current_user.id
    else
      current_user_id = nil
    end
    
    if params['user_id']
      #Like.toggle( current_user_id, params['user_id'], Like::USER )
      ZZ::Async::LikeClick.enqueue( current_user_id, params['user_id'], Like::USER )
      render :nothing => true and return
    elsif params['album_id']
      #Like.toggle( current_user_id, params['album_id'], Like::ALBUM )
      ZZ::Async::LikeClick.enqueue( current_user_id, params['album_id'], Like::ALBUM )
      render :nothing => true and return
    elsif params['photo_id']
      #Like.toggle( current_user_id, params['photo_id'], Like::PHOTO )
      ZZ::Async::LikeClick.enqueue( current_user_id, params['photo_id'], Like::PHOTO )
      render :nothing => true and return
    end

    render :nothing => true, status=> 400 and return
  end
  
end