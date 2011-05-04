#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

require 'mail'
class ContributorsController < ApplicationController
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

    #if !@album.admin?( current_user.id )
    #   raise Exception.new( "Only Album Admins can add contributors")
    #end

    if params[:contact_list].nil?
      flash[:error] = "contact_list parameter not present. Unable to add contributors"
      render :nothing =>true, :status => 404 and return
    end


    #split the comma seprated list into array removing any spaces before or after commma
    tokens = params[:contact_list].split(/\s*,\s*/)



      token_count = 0
      emails = []
      errors = []
      tokens.each do |t|
        begin
          e = Mail::Address.new( t )
          if e.domain   # An address like this 'foobar' is a valid local address with no domain so avoid it
            emails << e
          else
            errors << { :index => token_count, :token => t, :error => "Invalid Email Address" }
          end
        rescue Mail::Field::ParseError => e
          errors << { :index => token_count, :token => t, :error => "Invalid Email Address" }
        end
        token_count+= 1
      end

      if errors.length > 0
        flash[:error] = "Please delete and re-enter the highlighted contributor's"
        render :json => errors, :status => 200 and return
      end


    emails.each do | email|
        @album.add_contributor( email.address, params[:message] )
    end


    flash[:notice] = "The contributors were added to your album"
    render :json => "", :status => 200
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
