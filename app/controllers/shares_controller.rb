class SharesController < ApplicationController

  def index
    
  end

  def new
    @share = Share.new
    @album = Album.find(params[:album_id])
  end

  def create
    @share = Share.new(params[:share])
    @share.album_id = params[:album_id]
    @share.user_id = current_user.id


    if @share.save
      Mailer.deliver_shared_album_notification(@share, album_url(@share.album))  
    else
      render 'new'
    end
  end
end
