class ContactsController < ApplicationController
  before_filter :require_user

  def index
    commentable = Commentable.find_or_create_by_photo_id(params[:photo_id])




  end


end

