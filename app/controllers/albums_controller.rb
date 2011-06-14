#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class AlbumsController < ApplicationController
  before_filter :require_user,              :except => [ :index, :back_to_index, :my_albums_json, :liked_albums_json, :my_albums_public_json, :liked_albums_public_json, :liked_users_public_albums_json ]
  before_filter :require_user_json,         :only =>   [ :my_albums_json, :liked_albums_json ]
  before_filter :require_album,             :except => [ :index, :create, :new, :my_albums_json, :liked_albums_json, :my_albums_public_json, :liked_albums_public_json, :liked_users_public_albums_json  ]
  before_filter :require_album_admin_role,  :only =>   [ :destroy, :edit, :update ]

  # displays the "Select album type screen" used in the wizard
  def new
    render :layout => false
  end

  def create
    if params[:album_type].nil?
      render :text => "Error No Album Type Supplied. Please Choose Album Type.", :status=>500 and return
    end
    @album  = params[:album_type].constantize.new(:name => "New Album")
    @album.user = current_user
    unless @album.save
      current_user.albums << @album
      render :text => "Error in album create."+@album.errors.to_xml(), :status=>500 and return
    end
    render :json => {:id => @album.id, :name => @album.name}, :status => 200, :layout => false and return
  end

  # Used in the name tab of the wizard. It displays a preview
  # of what the album email will be as the album name changes
  # @album is set in the require_album before filter
  def preview_album_email
    if base = params[:album][:name]
      begin
        if @album.name_unique?( base )
          text = @album.normalize_friendly_id(FriendlyId::SlugString.new(base))
          slug_text = FriendlyId::SlugString.new(text.to_s).validate_for!(@album.friendly_id_config).to_s
          current_slug = @album.slugs.new(:name => slug_text.to_s, :scope => @album.friendly_id_config.scope_for(@album), :sluggable => @album)
          json = {
              :name  => base,
              :email => "#{current_slug.to_friendly_id}@#{@album.user.friendly_id}.#{Server::Application.config.album_email_host}",
              :url   => album_pretty_url(@album, current_slug.to_friendly_id)
          }
          render :json =>  json and return
        end
        flash[:error]="You already have an album named \"#{base}\" please try a different name"
        render :nothing => true , :layout => false, :status => 409
      rescue FriendlyId::ReservedError
        flash[:error]="Sorry, \"#{base}\" is a reserved album name please try a different one"
        render :nothing => true, :layout => false, :status => 409
      rescue FriendlyId::BlankError
        flash[:error]="Your album must have a name"
        render :nothing => true, :layout => false, :status => 409
      end
    else
      render :nothing => true, :layout => false, :status => 400
    end
  end

  # displays the name album page for the wizard
  # @album is set by the require album before filter
  def name_album
    render :layout => false
  end

  # displays the album privacy page for the wizard
  # @album is set by the require album before filter
  def privacy
    render :layout => false
  end

  # displays the edit page for the wizard
  # @album is set by the require album before filter
  def edit
    @photos = @album.photos
    render :layout => false
  end

  # updates @album attributes
  # @album is set by the require_album before_filter
  def update
    # The AlbumCoverPicker sends an empty string when no cover has been selected. Delete param if that is the case
    # TODO: Fix AlbumCoverPicker to omit cover_photo_id parameter if not set by user
    params[:album].delete(:cover_photo_id) if params[:album][:cover_photo_id] && params[:album][:cover_photo_id].length <= 0
    if @album && @album.update_attributes( params[:album] )
      flash.now[:notice] = "Album Updated!"
      render :text => 'Success Updating Album', :status => 200, :layout => false
    else
      #flash[:notice]="Your album update did not succeed please check X-Errors header for details"
      errors_to_headers( @album )
      render :text => 'Album update did not succeed', :status => 500, :layout => false
    end
  end


  # returns JSON used to populate
  # the "Group" tab
  def edit_group
    hash = @album.as_json
    hash[:group] = get_group_members
    render :json => hash
  end

  # change a group member from contributor to viewer
  # or vice-versa
  def update_group_member
    user_id = params[:member][:id]

    if params[:member][:permission] == 'contributor'
      role = AlbumACL::CONTRIBUTOR_ROLE
    else
      role = AlbumACL::VIEWER_ROLE
    end

    @album.acl.add_user(user_id, role)
    render :json => ''
  end

  # remove member from group
  def delete_group_member
    user_id = params[:member][:id]
    @album.acl.remove_user(user_id)
    render :json => ''
  end


  def add_group_members

    emails,errors = Share.validate_email_list(  params[:emails] )
    if errors.length > 0
      #todo: just ignore errors. might want to fix this alter
    end


    if params[:permission] == 'contributor'
      type = Share::TYPE_CONTRIBUTOR_INVITE
    else
      type = Share::TYPE_VIEWER_INVITE
    end


    share = Share.new(:user =>         current_user,
                      :subject =>     @album,
                      :subject_url => album_pretty_url(@album),
                      :service =>     Share::SERVICE_EMAIL,
                      :recipients =>  emails,
                      :share_type =>  type,
                      :message    =>  params[:message])

    share.save!

    render :json => get_group_members
  end

  def group_members
    render :json => get_group_members
  end






# This is effectively the users homepage
  def index
    @user = User.find(params[:user_id])

    store_last_home_page @user.id

    # Note For Jeremy:
    # This section would be used when you build the index page and set up the json links for the 3 types
    # of album data

    # determine if we should be fetching the view based on public or private data
    user_is_me = current_user?(@user)
    public = (user_is_me || (!current_user.nil? && current_user.support_hero?)) == false

    # preload the expected cache data
    loader = Cache::Album::Manager.shared.make_loader(@user, public)
    loader.pre_fetch_albums
    versions = loader.current_versions

    # call the following methods to get the json paths for my_albums, my_liked_albums, etc
    # The url paths returned are based on whether we are viewing ourselves or somebody else (based on the public flag)
    #
    # The paths are relative to the host so start with /service/...
    @my_albums_path = my_albums_path(versions)
    @liked_albums_path = liked_albums_path(versions)
    @liked_users_albums_path = liked_users_albums_path(versions)
    @session_user_liked_albums_path = nil

    # When showing the view for a user who is not the current user we
    # fetch the public information.  However, if we have a current user
    # and that user likes and can see one or more of the other users
    # albums we must merge the view on the client by checking to see
    # if any of the albums the current user likes belong to the viewed user
    # we do this by returning the url to fetch liked_albums for the session
    # user
    if public && !current_user.nil?
      # ok, we have a valid session user and we are viewing somebody else so pull in our liked_albums
      sess_loader = Cache::Album::Manager.shared.make_loader(current_user, false)
      sess_loader.pre_fetch_albums
      sess_versions = sess_loader.current_versions
      @session_user_liked_albums_path = liked_albums_path(sess_versions)
    end


#    liked_users_public_albums = @user.liked_users_public_albums
    # if we are showing the owners albums, show them all as well as any linked albums and any public albums for users that the user likes
    # for a different user than the current logged in user, just show all public albums including any that the users likes and
    # any public ones that get pulled in from users that we like
    # When the user visits her hompage show
    #    -All of her albums
    #    -All he liked albums
    #    -All of her liked users public albums
    # When the user visits joe's homepage show
    #    -All of joe's user public albums
    #    -All of joe's liked public albums
    #    -All of joe's lked users' public albums
#    if public == false
#      @albums = @user.albums | @user.liked_albums | liked_users_public_albums #show all of current_user's albums
#    else
#      @albums = @user.albums.where("privacy = 'public' AND completed_batch_count > 0") |
#                @user.liked_public_albums | liked_users_public_albums
#    end
    #@albums = @albums.sort { |a1, a2| a2.updated_at <=> a1.updated_at }

    #Setup badge vars
    @badge_name = @user.name
  end

# Some helpers to return the json paths, would be cleaner if these lived in Versions class but we need
# the route helpers accessible to controller
  def my_albums_path(versions, force_zero_ver = false)
    ver = force_zero_ver ? 0 : versions.my_albums
    url = versions.public ? my_albums_public_json_path(versions.user_id) : my_albums_json_path(versions.user_id)
    url << "?ver=#{ver}"
  end

  def liked_albums_path(versions, force_zero_ver = false)
    ver = force_zero_ver ? 0 : versions.liked_albums
    url = versions.public ? liked_albums_public_json_path(versions.user_id) : liked_albums_json_path(versions.user_id)
    url << "?ver=#{ver}"
  end

  def liked_users_albums_path(versions, force_zero_ver = false)
    ver = force_zero_ver ? 0 : versions.liked_users_albums
    liked_users_public_albums_json_path(versions.user_id) + "?ver=#{ver}"
  end

  def albums_cache_setup(public)
    @user = User.find(params[:user_id])
    loader = Cache::Album::Manager.shared.make_loader(@user, public)
  end

  def render_cached_json(json, public)
    ver = params[:ver]
    if ver.nil? || ver == 0
      # no cache
      expires_now
    else
      expires_in 1.year, :public => public
    end
    response.headers['Content-Encoding'] = "gzip"
    render :json => json
  end

# the calls to fetch json for various album parts

  def my_albums_json_common(public)
    loader = albums_cache_setup(public)
    versions = loader.current_versions
    ver_time = Time.at(versions.my_albums).utc
    etag = versions.my_albums_etag

    if stale?(:last_modified => ver_time, :etag => etag)
      json = loader.fetch_my_albums_json
      render_cached_json(json, public)
    end
  end

# fetch my own albums
  def my_albums_json
    my_albums_json_common(false)
  end

# fetch public albums for a given user
  def my_albums_public_json
    my_albums_json_common(true)
  end

  def liked_albums_json_common(public)
    loader = albums_cache_setup(public)
    versions = loader.current_versions
    ver_time = Time.at(versions.liked_albums).utc
    etag = versions.liked_albums_etag

    if stale?(:last_modified => ver_time, :etag => etag)
      json = loader.fetch_liked_albums_json
      render_cached_json(json, public)
    end
  end

# fetch the albums I like
  def liked_albums_json
    liked_albums_json_common(false)
  end

# fetch the albums that a given user likes
  def liked_albums_public_json
    liked_albums_json_common(true)
  end

# fetch the public albums of a user we like
  def liked_users_public_albums_json
    public = true
    loader = albums_cache_setup(public)
    versions = loader.current_versions
    ver_time = Time.at(versions.liked_users_albums).utc
    etag = versions.liked_users_albums_etag

    if stale?(:last_modified => ver_time, :etag => etag)
      json = loader.fetch_liked_users_albums_json
      render_cached_json(json, public)
    end
  end

#deletes an album
#@album is set by require_album before_filter
  def destroy
    # Album is found when the before filter calls authorized user
    if @album.destroy
      render :json => "Album deleted" and return
    else
      render :json => @album.errors, :status=>500 and return
    end
  end

#closes the current batch
# we also have a watchdog sweeper that will
# close batches with no new add activity after a 5 minute window
  def close_batch
    album_id = params[:id]
    if album_id
      UploadBatch.close_batch( current_user.id, album_id)
    end
    render :nothing => true
  end

#displays the "You have reached a password protected album, request access" dialog
  def pwd_dialog
    render :layout => false
  end

# Receives and processes a user's request for access into a password protected album
  def request_access
    #TODO: Receive and process current_users request for access into the current album
  end


  private
#
# To be run as a before_filter
# Requires params[:id] to be present and be a valid album_id.
# sets @album to be Album.find( params[:id ])
# Throws ActiveRecord:RecordNotFound exception if params[:id] is not present or the album is not found
  def require_album
    begin
      @album = Album.find( params[:id ])  #will trhow exception if params[:id] is not defined or album not found
    rescue ActiveRecord::RecordNotFound => e
      flash.now[:error] = "This operation requires an album, we could not find one because: "+e.message
      if request.xhr?
        head   :not_found
      else
        render :file => "#{Rails.root}/public/404.html", :status => 404
      end
      return false
    end
  end

  def get_group_members
    group = []


    # collect contributors
    #
    @album.contributors( true ).each do |id|
      user = User.find_by_id( id )
      if user
        group << { :id => id, :name => user.formatted_email, :permission => "contributor" }
      else
        contact = current_user.contacts.find_by_address( id )
        if contact
          group << { :id => id, :name => contact.formatted_email, :permission => "contributor" }
        else
          group << { :id => id, :name => id, :permission => "contributor" }
        end
      end
    end

    # collect viewers
    #
    @album.viewers( true ).each do |id|
      user = User.find_by_id( id )
      if user
        group << { :id => id, :name => user.formatted_email, :permission => "viewer" }
      else
        contact = current_user.contacts.find_by_address( id )
        if contact
          group << { :id => id, :name => contact.formatted_email, :permission => "viewer" }
        else
          group << { :id => id, :name => id , :permission => "viewer"}
        end
      end
    end

    return group
  end

end
