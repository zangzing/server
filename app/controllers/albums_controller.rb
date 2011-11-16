#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class AlbumsController < ApplicationController
  # methods that should be in except lists since they are open or manged by an only
  # the list was getting out of hand having to include twice
  # this is the common set the is excepted from require_user and require_album
  def self.except_methods
    return [
        :index, :invalidate_cache, :zz_api_albums,
        :my_albums_json, :liked_albums_json, :my_albums_public_json, :liked_albums_public_json, :liked_users_public_albums_json,
        :zz_api_my_albums_json, :zz_api_liked_albums_json, :zz_api_my_albums_public_json, :zz_api_liked_albums_public_json, :zz_api_liked_users_public_albums_json,
        :invited_albums_json, :zz_api_invited_albums_json
    ]
  end

  before_filter :require_user,              :except => except_methods + [ :download ]
  before_filter :require_same_user_json,    :only =>   [ :my_albums_json, :liked_albums_json, :zz_api_my_albums_json, :zz_api_liked_albums_json,
      :invited_albums_json, :zz_api_invited_albums_json, :invalidate_cache
  ]
  before_filter :require_album,             :except => except_methods + [ :create, :new ]
  before_filter :require_album_admin_role,  :only =>   [ :destroy, :edit, :update, :add_group_members ]

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

  def zz_api_update
    zz_api do

    end
  end






  # returns JSON used to populate
  # the "Group" tab
  def edit_group
    hash = {
        :user => {
          :has_facebook_token => !current_user.identity_for_facebook.credentials_valid?.nil?,
          :has_twitter_token => !current_user.identity_for_twitter.credentials_valid?.nil?
        },
        :album => @album.as_json,
        :group => get_group_members,
        :share => {
               :facebook => {
                  :message => "",
                  :title => "#{@album.name} by #{@album.user.name}",
                  :url => album_pretty_url(@album),
                  :description => SystemSetting[:facebook_post_description],
                  :photo => @album.cover ? @album.cover.thumb_url : nil
               },
               :twitter => {
                   :message => "Check out #{@album.user.posessive_name} #{@album.name} Album on @ZangZing #{bitly_url(album_pretty_url(@album))}"
               }
            }
        }
    

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

    Share.create!(    :user =>         current_user,
                      :subject =>     @album,
                      :subject_url => album_pretty_url(@album),
                      :service =>     Share::SERVICE_EMAIL,
                      :recipients =>  emails,
                      :share_type =>  type,
                      :message    =>  params[:message])

    if type == Share::TYPE_CONTRIBUTOR_INVITE
       emails.each { |email| @album.add_contributor( email )}
    else
       emails.each { |email| @album.add_viewer( email )}
    end

    zza.track_event('album.share.email')

    render :json => get_group_members
  end

  def group_members
    render :json => get_group_members
  end


  # fetches the album paths, this is common code shared
  # between zz_api and normal apis
  # returns @loader, and @session_loader context which
  # can be used to create the specific form of data that
  # each type of call wants
  def get_albums(user, zz_api)
    # determine if we should be fetching the view based on public or private data
    user_is_me = current_user?(user)
    private_view = user_is_me || (!current_user.nil? && current_user.support_hero?)
    public = !private_view

    # preload the expected cache data
    loader = Cache::Album::Manager.shared.make_loader(user, public)
    loader.pre_fetch_albums

    # call the following methods to get the json paths for my_albums, my_liked_albums, etc
    # The url paths returned are based on whether we are viewing ourselves or somebody else (based on the public flag)
    #
    # The paths are relative to the host so start with /service/...
    session_loader = nil

    # When showing the view for a user who is not the current user we
    # fetch the public information.  However, if we have a current user
    # and that user likes and can see one or more of the other users
    # albums we must merge the view on the client by checking to see
    # if any of the albums the current user likes belong to the viewed user
    # we do this by returning the url to fetch liked_albums for the session
    # user
    if public && !current_user.nil?
      # ok, we have a valid session user and we are viewing somebody else so pull in our liked_albums
      session_loader = Cache::Album::Manager.shared.make_loader(current_user, false)
      session_loader.pre_fetch_albums
    end

    @loader = loader
    @session_loader = session_loader
  end

  # This is effectively the users homepage
  def index
    begin
      @user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      user_not_found_redirect_to_homepage_or_potd
      return
    end

    store_last_home_page @user.id

    get_albums(@user, false)

    @badge_name = @user.name
    @my_albums_path = my_albums_path(@loader)
    @liked_albums_path = liked_albums_path(@loader)
    @liked_users_albums_path = liked_users_albums_path(@loader)
    @invited_albums_path = invited_albums_path(@loader)
    @session_user_liked_albums_path = @session_loader.nil? ? nil : liked_albums_path(@session_loader)
    @session_user_invited_albums_path = @session_loader.nil? ? nil : invited_albums_path(@session_loader)
  end


  def zz_api_albums()
    zz_api do
      user = User.find(params[:user_id])

      get_albums(user, true)
      loader = @loader
      session_loader = @session_loader
      if !session_loader.nil?
        session_liked_users_albums = session_loader.liked_users_album_loader.current_version_key
        session_liked_users_albums_path = zz_api_liked_users_albums_path(session_loader)
        session_invited_albums = session_loader.invited_album_loader.current_version_key
        session_invited_albums_path = zz_api_invited_albums_path(session_loader)
      else
        session_liked_users_albums = nil
        session_liked_users_albums_path = nil
        session_invited_albums = nil
        session_invited_albums_path = nil
      end

      album_meta = {
        :user_id                        => loader.user_id,
        :logged_in_user_id              => current_user.nil? ? nil : current_user.id,
        :public                         => loader.public,
        :my_albums                      => loader.my_album_loader.current_version_key,
        :my_albums_path                 => zz_api_my_albums_path(loader),
        :liked_albums                   => loader.liked_album_loader.current_version_key,
        :liked_albums_path              => zz_api_liked_albums_path(loader),
        :liked_users_albums             => loader.liked_users_album_loader.current_version_key,
        :liked_users_albums_path        => zz_api_liked_users_albums_path(loader),
        :session_user_liked_albums      => session_liked_users_albums,
        :session_user_liked_albums_path => session_liked_users_albums_path,
        :invited_albums                 => loader.invited_album_loader.current_version_key,
        :invited_albums_path            => zz_api_invited_albums_path(loader),
        :session_user_invited_albums      => session_invited_albums,
        :session_user_invited_albums_path => session_invited_albums_path
      }
    end
  end

  # invalidate the current cache for this user - essentially a forced cache flush version change
  def invalidate_cache
    user_id = params[:user_id]
    Cache::Album::Manager.shared.user_invalidate_cache(user_id)
    render :json => ''
  end


# Some helpers to return the json paths, would be cleaner if these lived in Versions class but we need
# the route helpers accessible to controller
  def my_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.my_album_loader.current_version_key
    url = loader.public ? my_albums_public_json_path(loader.user_id) : my_albums_json_path(loader.user_id)
    url << "?ver=#{ver}"
  end

  def zz_api_my_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.my_album_loader.current_version_key
    url = loader.public ? zz_api_my_albums_public_json_path(loader.user_id) : zz_api_my_albums_json_path(loader.user_id)
    url << "?ver=#{ver}"
  end

  def liked_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.liked_album_loader.current_version_key
    url = loader.public ? liked_albums_public_json_path(loader.user_id) : liked_albums_json_path(loader.user_id)
    url << "?ver=#{ver}"
  end

  def zz_api_liked_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.liked_album_loader.current_version_key
    url = loader.public ? zz_api_liked_albums_public_json_path(loader.user_id) : zz_api_liked_albums_json_path(loader.user_id)
    url << "?ver=#{ver}"
  end

  def liked_users_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.liked_users_album_loader.current_version_key
    liked_users_public_albums_json_path(loader.user_id) + "?ver=#{ver}"
  end

  def zz_api_liked_users_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.liked_users_album_loader.current_version_key
    zz_api_liked_users_public_albums_json_path(loader.user_id) + "?ver=#{ver}"
  end

  def invited_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.invited_album_loader.current_version_key
    invited_albums_json_path(loader.user_id) + "?ver=#{ver}"
  end

  def zz_api_invited_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.invited_album_loader.current_version_key
    zz_api_invited_albums_json_path(loader.user_id) + "?ver=#{ver}"
  end

  def albums_cache_setup(public)
    @user = User.find(params[:user_id])
    return Cache::Album::Manager.shared.make_loader(@user, public)
  end

# the calls to fetch json for various album parts

  # pass the loader that you want to use and the public flag
  def cached_albums_json_common(album_loader, public)
    etag = album_loader.etag

    if stale?(:etag => etag)
      json = album_loader.fetch_loaded_json
      render_cached_json(json, public, album_loader.compressed)
    end
  end

  def my_albums_json_common(public)
    loader = albums_cache_setup(public)
    album_loader = loader.my_album_loader
    cached_albums_json_common(album_loader, public)
  end

# fetch my own albums
  def my_albums_json
    my_albums_json_common(false)
  end

  def zz_api_my_albums_json
    zz_api_self_render do
      my_albums_json_common(false)
    end
  end

# fetch public albums for a given user
  def my_albums_public_json
    my_albums_json_common(true)
  end

  def zz_api_my_albums_public_json
    zz_api_self_render do
      my_albums_json_common(true)
    end
  end

  def liked_albums_json_common(public)
    loader = albums_cache_setup(public)
    album_loader = loader.liked_album_loader
    cached_albums_json_common(album_loader, public)
  end

# fetch the albums I like
  def liked_albums_json
    liked_albums_json_common(false)
  end

  def zz_api_liked_albums_json
    zz_api_self_render do
      liked_albums_json_common(false)
    end
  end

# fetch the albums that a given user likes
  def liked_albums_public_json
    liked_albums_json_common(true)
  end

  def zz_api_liked_albums_public_json
    zz_api_self_render do
      liked_albums_json_common(true)
    end
  end

# fetch the public albums of a user we like
  def invited_albums_json_common
    public = false  # private only since we can only be here if they are the owner
    loader = albums_cache_setup(public)
    album_loader = loader.invited_album_loader
    cached_albums_json_common(album_loader, public)
  end

  def invited_albums_json
    invited_albums_json_common
  end

  def zz_api_invited_albums_json
    zz_api_self_render do
      invited_albums_json_common
    end
  end

  # the albums we have been invited to, only shows for your own request
  # public gets an empty list
  def liked_users_public_albums_json_common
    public = true
    loader = albums_cache_setup(public)
    album_loader = loader.liked_users_album_loader
    cached_albums_json_common(album_loader, public)
  end

  def liked_users_public_albums_json
    liked_users_public_albums_json_common
  end

  def zz_api_liked_users_public_albums_json
    zz_api_self_render do
      liked_users_public_albums_json_common
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

  # @album is set by require_album before_filter
  # prepare to download an on the fly zip of the photos
  # we return.  The heavy lifting is handled by the mod_zip
  # plugin to nginx, so our job is to put together the list
  # of all photos that have been uploaded to amazon
  def download
    unless  @album.can_user_download?( current_user )
      flash.now[:error] = "Only Authorized Album Group Members can download albums"
      if request.xhr?
        head :status => 401
      else
        render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      end
      return false
    end

    # Walk the list of all photos and build a plain test response in the form
    # crc32 size custom_url name_in_zip_file
    # since we just added crc32 some files don't have it so it is permissible for it
    # to be just a -.  When we perform the next full photos resize sweep we can compute
    # and add it to those that are missing.   The benifit to having this is that it
    # gives us restartable downloads from an arbitrary point.
    #
    # The custom_url must be of the form
    # /nginx_redirect/host/uri
    # the nginx_redirect part tells us to proxy through to a remote
    # server to fetch the actual contents for that file
    #
    files = ""
    i = 0
    @album.photos.each do |photo|
      i += 1
      image_path = photo.image_path
      image_file_size = photo.image_file_size.nil? ? 0 : photo.image_file_size.to_i
      if image_path && image_file_size > 0
        full_name = photo.file_name_with_extention(i)
        escaped_url = URI::escape(image_path.to_s)
        uri = URI.parse(escaped_url)
        query = uri.query.blank? ? '' : "?#{uri.query}"
        crc32 = photo.crc32.nil? ? '-' : photo.crc32.to_s(16)
        files << "#{crc32} #{image_file_size} /nginx_redirect/#{uri.host}#{uri.path}#{query} #{full_name}\n"
      end
    end

    if files.blank?
      flash[:error]="Album has no photos ready for download"
      head :not_found and return
    else
      zza.track_event("albums.download.full")
      Rails.logger.debug("Full album download: #{@album.name}")
      nginx_zip_mod(@album.name, files) and return
    end
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
        group << { :id => id, :name => user.formatted_email, :permission => "contributor", :profile_photo_url => user.profile_photo_url }
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
        group << { :id => id, :name => user.formatted_email, :permission => "viewer", :profile_photo_url => user.profile_photo_url }
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
