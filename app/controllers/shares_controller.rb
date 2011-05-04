#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class SharesController < ApplicationController

  layout false

  respond_to :html, :only => [:new, :newpost, :newemail]
  respond_to :json, :only => [:create]

  def new
  end

  def newpost
    @share = Share.new()
    @twitter  = ( current_user.identity_for_twitter.credentials_valid? ? "1" :"0" )
    @facebook = ( current_user.identity_for_facebook.credentials_valid? ? "1" :"0" )
  end

  def newemail
    @share = Share.new()
  end

  def create
    # Based on the route used to get here (and thus the params) we know what kind of subject does
    # the user wants to quack! about.
    if  params[:user_id]
      @subject = User.find(params[:user_id])
      @subject_type = Like::USER
      @subject_url = user_pretty_url(@subject)
    elsif params[:album_id]
      @subject = Album.find(params[:album_id])
      @subject_type = Like::ALBUM
      @subject_url = album_pretty_url(@subject)
    elsif params[:photo_id]
      @subject = Photo.find(params[:photo_id])
      @subject_type = Like::PHOTO
      @subject_url = photo_pretty_url(@subject)
    else
      render :json => "subject_type not specified via params", :status => 400 and return
    end

    # make sure recipients its an array
    # emailshare submits a comma separated list of emails
    # postshare submits an array of social services
    if params[:recipients].is_a?(Array)
      @rcp = params[:recipients] #this is post share
    else
      # We are in an email, validate emails, if they ALL pass create share otherwise return error info
      emails,errors = validate_email_list(  params[:recipients] )
      if errors.length > 0
        flash[:error] = "Please verify highlighted addresses"
        render :json => errors, :status => 200 and return
      end
      @rcp = emails
    end

    @share = Share.new( :user =>        current_user,
                        :subject =>     @subject,
                        :subject_url => @subject_url,
                        :service =>     params[:service],
                        :recipients =>  @rcp,
                        :message    =>  params[:message])

    unless @share.save
      errors_to_headers( @share )
      render :json => "", :status => 400 and return
    end

    flash[:notice] = "The user homepage " if @share.user?
    flash[:notice] = "The album " if @share.album?
    flash[:notice] = "The photo " if @share.photo?

    if @share.instant?
      flash[:notice] += "has been shared."
    else
      flash[:notice] += "will be shared as soon as it is ready."
    end
    render :json =>"", :status => 200
  end


  def new_twitter_share
    if  params[:user_id]
      user = User.find(params[:user_id])
      shareable_url = user_pretty_url(user)
      message = "Check out #{user.posessive_name} Albums on @ZangZing"
    elsif params[:album_id]
      album = Album.find(params[:album_id])
      shareable_url = album_pretty_url(album)
      message = "Check out #{album.user.posessive_name} #{album.name} on @ZangZing"
    elsif params[:photo_id]
      photo = Photo.find(params[:photo_id])
      shareable_url = photo_pretty_url(photo)
      message = "Check out #{photo.user.posessive_name} photo on @ZangZing"
    end

    redirect_to "http://twitter.com/share?text=#{URI.escape message}&url=#{URI.escape shareable_url}"

  end

  def new_facebook_share
    if  params[:user_id]
      user = User.find(params[:user_id])
      shareable_url = user_pretty_url(user)
    elsif params[:album_id]
      album = Album.find(params[:album_id])
      shareable_url = album_pretty_url(album)
    elsif params[:photo_id]
      photo = Photo.find(params[:photo_id])
      shareable_url = photo_pretty_url(photo)
    end

    redirect_to "http://www.facebook.com/share.php?u=#{URI.escape shareable_url}"

  end

  def new_mailto_share
    if  params[:user_id]
      user = User.find(params[:user_id])
      shareable_url = user_pretty_url(user)
      subject = "Check out a ZangZing homepage"
      message = "Hi, I thought you would like to see this ZangZing homepage.\n\n #{shareable_url}"
    elsif params[:album_id]
      album = Album.find(params[:album_id])
      shareable_url = album_pretty_url(album)
      subject = "Check out #{album.name} album on ZangZing"
      message = "Hi, I thought you would like to see #{album.user.posessive_name} #{album.name} album on ZangZing.\n\n #{shareable_url}"
    elsif params[:photo_id]
      photo = Photo.find(params[:photo_id])
      shareable_url = photo_pretty_url(photo)
      subject = "Check out this photo on ZangZing"
      message = "Hi, I thought you would like to see #{photo.user.posessive_name} photo on ZangZing.\n\n #{shareable_url}"
    end

    render :json=> {:mailto => "mailto:?subject=#{URI.escape subject}&body=#{URI.escape message}"}

  end





  private

  def validate_email_list( email_list )
    #split the comma seprated list into array removing any spaces before or after commma
    tokens = email_list.split(/\s*,\s*/)

    # Loop through the tokens and add the bad ones to the errors array
    token_index = 0
    emails = []
    errors = []
    tokens.each do |t|
      begin
        e = Mail::Address.new( t )
        # An address like 'foobar' is a valid local address with no domain so avoid it
        raise Mail::Field::ParseError.new if e.domain.nil?
        emails << e.address #TODO: Email validator in share.rb does not handle formatted_emails just the address
      rescue Mail::Field::ParseError
        errors << { :index => token_index, :token => t, :error => "Invalid Email Address" }
      end
      token_index+= 1
    end
    return emails,errors
  end

end