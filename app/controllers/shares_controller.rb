class SharesController < ApplicationController

  layout false

  def index   
  end

  def new
     @album = Album.find(params[:album_id])
  end

  def newpost
      @album = Album.find(params[:album_id])
      @share = PostShare.new
      @share.recipients.build(:name => 'Twitter')
      @share.recipients.build(:name => 'Facebook')
  end

  def newmail
    @album = Album.find(params[:album_id])
    @share = MailShare.new
    
    @google_id = current_user.identity_for_google
    @yahoo_id  = current_user.identity_for_yahoo
    @contacts = []
    @contacts.concat @google_id.contacts unless @google_id.nil?
    @contacts.concat @yahoo_id.contacts unless @yahoo_id.nil?  

  end
  
  def create
    @album = Album.find(params[:album_id])
    @share = Share.factory( current_user, @album, params)
    if @share.save
       flash[:success] = "You will be notified and your album will be shared as soon as your photos finish uploading"
       render 'new'
    else
      render 'newmail' and return  if params[:mail_share]
      render 'newpost' and return  if params[:post_share]
    end
  end

  def edit
    @mail_share = Share.find(params[:id]) 
    @album = @mail_share.album
    render :new, :layout => false
  end
end
