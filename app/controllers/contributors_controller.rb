#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

require 'mail'
class ContributorsController < ApplicationController
  include PrettyUrlHelper


  before_filter :require_user
  layout false

  respond_to :html, :only => [:new, :index]
  respond_to :json, :only => [:index, :create, :destroy]

  def new
    @album = current_user.albums.find(params[:album_id])
  end

  # Creates contributors for the album.
  # Expects a comma separated list of emails
  #
  # Contributors are stored in the Album''s contributor acl.
  # The values in the acl maybe the user_id of the contributor
  # or the email address of the contributor if the contributor
  # is not yet a user.
  def create
    fetch_album

    if params[:contact_list].nil?
      flash[:error] = "contact_list parameter not present. Unable to add contributors"
      render :nothing =>true, :status => 404 and return
    end

    emails,errors = Share.validate_email_list(  params[:contact_list] )
    if errors.length > 0
      flash[:error] = "Please delete and re-enter the highlighted contributor's"
      render :json => errors, :status => 200 and return
    end


    @share = Share.new(:user =>        current_user,
                       :subject =>     @album,
                       :subject_url => album_pretty_url(@album),
                       :service =>     Share::SERVICE_EMAIL,
                       :recipients =>  emails,
                       :share_type =>  Share::TYPE_CONTRIBUTOR_INVITE,
                       :message    =>  params[:message])

    if @share.save
      flash[:notice] = "The contributors were added to your album"
      render :json => "", :status => 200 and return
    else
      errors_to_headers( @share )
      render :json => "", :status => 400 and return

    end

  end


  def index
    fetch_album

    contributor_ids = @album.contributors( true ) #exact, only contributors we do not want album admins here

    @results = []
    contributor_ids.each do |id|
      user = User.find_by_id( id )
      if user
        @results << { :id => id, :name => CGI::escapeHTML(user.formatted_email) }
      else
        contact = current_user.contacts.find_by_address( id )
        if contact
          @results << { :id => id, :name => CGI::escapeHTML(contact.formatted_email) }
        else
          @results << { :id => id, :name => id }
        end
      end
    end

    respond_with( @results )
  end

  def destroy
    fetch_album
    #if !@album.admin?( current_user.id )
    #   raise Exception.new( "Only Album Admins can add contributors")
    #end
    @album.remove_contributor( params[:id] )
    flash[:notice] = "Contributor deleted"
    render :nothing => true
  end



  def old_create
    @album = current_user.albums.find(params[:album_id])
    if @album.nil?
      flash[:error] = "Album not found. Unable to add contributors"
      respond_to do |format|
        format.html  { render :action => 'new' and return }
        format.json { render :json =>{:status => 404, :flash => flash } and return }
      end
    else
      begin
        Contributor.factory( @album, params[:email_share][:to])
        @album.save!
      rescue ActiveRecord::RecordInvalid => invalid
        respond_to do |format|
          format.html  { redirect_to new_album_contributors_url(@album)   }
          format.json  { errors_to_headers( invalid.record )
          render :json => "", :status => 400 and return}
        end
      end

      flash[:notice] = "The contributors were added to your album"
      respond_to do |format|
        format.html  { redirect_to album_url(@album)   }
        format.json { render :json => "", :status => 200 and return }
      end
    end
  end




  protected

  def fetch_album
    @album = current_user.albums.find_by_id(params[:album_id]) #use find_by_id to avoid exception if not found
    if @album.nil?
      flash[:error] = "Album could not be found."
      render :status => 404
    end
  end

end
