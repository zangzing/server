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
      share_event = 'user'
    elsif params[:album_id]
      @subject = Album.find(params[:album_id])
      @subject_type = Like::ALBUM
      @subject_url = album_pretty_url(@subject)
      share_event = 'album'
    elsif params[:photo_id]
      @subject = Photo.find(params[:photo_id])
      @subject_type = Like::PHOTO
      @subject_url = photo_pretty_url(@subject)
      share_event = 'photo'
    else
      render :json => "subject_type not specified via params", :status => 400 and return
    end

    # make sure recipients its an array
    # emailshare submits a comma separated list of emails
    # postshare submits an array of social services
    if params[:recipients].is_a?(Array)
      @rcp = params[:recipients] #this is post share
      if params[:recipients].include?('twitter')
        zza.track_event("#{share_event}.share.twitter")
      end
      if params[:recipients].include?('facebook')
        zza.track_event("#{share_event}.share.facebook")
      end
    else
      # We are in an email, validate emails, if they ALL pass
      # create share otherwise return error info
      zza.track_event("#{share_event}.share.email")
      emails, errors, addresses, group_ids = Group.filter_groups_and_emails(current_user.id, params[:recipients])
      # ok, if we have things that aren't valid emails or group names
      # report it to the user
      if errors.length > 0
        flash[:error] = "Please verify highlighted addresses"
        render :json => errors, :status => 200 and return
      end

      # if sharing album by album owner, then add recipients to group
      if @subject.is_a?(Album)
        album = @subject
        if album.admin?( current_user.id )
          # create automatic users if needed
          users, user_id_to_email = User.convert_to_users(addresses, current_user, true)
          view_group_ids = group_ids + users.map(&:my_group_id)
          album.add_viewers(view_group_ids)
        end
      end

      @rcp = emails + group_ids
    end

    @share = Share.new( :user =>        current_user,
                        :subject =>     @subject,
                        :subject_url => @subject_url,
                        :service =>     params[:service],
                        :recipients =>  @rcp,
                        :share_type =>  Share::TYPE_VIEWER_INVITE,
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
      zza.track_event('user.share.twitter')
    elsif params[:album_id]
      album = Album.find(params[:album_id])
      shareable_url = album_pretty_url(album)
      message = "Check out #{album.user.posessive_name} #{album.name} Album on @ZangZing"
      zza.track_event('album.share.twitter')
    elsif params[:photo_id]
      photo = Photo.find(params[:photo_id])
      shareable_url = photo_pretty_url(photo)
      message = "Check out #{photo.user.posessive_name} photo on @ZangZing"
      zza.track_event('photo.share.twitter')
    end

    shareable_url = bitly_url(shareable_url)
    redirect_to "http://twitter.com/share?text=#{URI.escape message}&url=#{URI.escape shareable_url}"

  end

  def new_facebook_share
    if  params[:user_id]
      user = User.find(params[:user_id])
      shareable_url = user_pretty_url(user)
      zza.track_event('user.share.facebook')
    elsif params[:album_id]
      album = Album.find(params[:album_id])
      shareable_url = album_pretty_url(album)
      zza.track_event('album.share.facebook')
    elsif params[:photo_id]
      photo = Photo.find(params[:photo_id])
      shareable_url = photo_pretty_url(photo)
      zza.track_event('photo.share.facebook')
    end

    redirect_to "http://www.facebook.com/share.php?u=#{URI.escape shareable_url}"

  end

  def new_mailto_share
    if  params[:user_id]
      user = User.find(params[:user_id])
      shareable_url = user_pretty_url(user)
      shareable_url = bitly_url(shareable_url)
      subject = "Check out a ZangZing homepage"
      message = "Hi, I thought you would like to see this ZangZing homepage.\n\n #{shareable_url}"
      zza.track_event('user.share.email')

    elsif params[:album_id]
      album = Album.find(params[:album_id])
      shareable_url = album_pretty_url(album)
      shareable_url = bitly_url(shareable_url)
      subject = "Check out #{album.name} album on ZangZing"
      message = "Hi, I thought you would like to see #{album.user.posessive_name} #{album.name} album on ZangZing.\n\n #{shareable_url}"
      zza.track_event('album.share.email')

    elsif params[:photo_id]
      photo = Photo.find(params[:photo_id])
      shareable_url = photo_pretty_url(photo)
      shareable_url = bitly_url(shareable_url)
      subject = "Check out this photo on ZangZing"
      message = "Hi, I thought you would like to see #{photo.user.posessive_name} photo on ZangZing.\n\n #{shareable_url}"
      zza.track_event('photo.share.email')

    end

    render :json=> {:mailto => "mailto:?subject=#{URI.escape subject}&body=#{URI.escape message}"}

  end







end