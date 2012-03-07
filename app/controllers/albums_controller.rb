#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class AlbumsController < ApplicationController
  ssl_allowed :set_latest_cover
  # NOTE: this controller has been converted to use the new return unless filter style
  # of calling explicitly in each controller method.
  #
  #
  #
  # methods that should be in except lists since they are open or manged by an only
  # the list was getting out of hand having to include twice
  # this is the common set the is excepted from require_user and require_album
  #def self.except_methods
  #  return [
  #      :index, :invalidate_cache, :zz_api_albums,
  #      :my_albums_json, :liked_albums_json, :my_albums_public_json, :liked_albums_public_json, :liked_users_public_albums_json,
  #      :zz_api_my_albums_json, :zz_api_liked_albums_json, :zz_api_my_albums_public_json, :zz_api_liked_albums_public_json, :zz_api_liked_users_public_albums_json,
  #      :invited_albums_json, :zz_api_invited_albums_json
  #  ]
  #end
  #
  #before_filter :require_user,              :except => except_methods + [ :download ]
  #before_filter :require_same_user_json,    :only =>   [ :my_albums_json, :liked_albums_json, :zz_api_my_albums_json, :zz_api_liked_albums_json,
  #    :invited_albums_json, :zz_api_invited_albums_json, :invalidate_cache
  #]
  #before_filter :require_album,             :except => except_methods + [ :create, :new ]
  #before_filter :require_album_admin_role,  :only =>   [ :destroy, :edit, :update, :add_group_members ]

  # displays the "Select album type screen" used in the wizard
  def new
    return unless require_user
    render :layout => false
  end

  def create
    return unless require_user
    if params[:album_type].nil?
      render :text => "Error No Album Type Supplied. Please Choose Album Type.", :status=>500 and return
    end
    @album  = params[:album_type].constantize.new(:name => Album::DEFAULT_NAME)
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
    return unless require_user && require_album && require_album_admin_role
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
    return unless require_user && require_album && require_album_admin_role
    render :layout => false
  end

  # displays the album privacy page for the wizard
  # @album is set by the require album before filter
  def privacy
    return unless require_user && require_album && require_album_admin_role
    render :layout => false
  end

  # displays the edit page for the wizard
  # @album is set by the require album before filter
  def edit
    return unless require_user && require_album && require_album_admin_role
    @photos = @album.photos
    render :layout => false
  end

  # updates @album attributes
  # @album is set by the require_album before_filter
  def update
    return unless require_user && require_album && require_album_admin_role
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

  # shared code for album update and creation that
  # throws a friendly error message from the exception or error
  # If it gets an exception it doesn't understand it simply
  # returns that exception
  def friendly_error(ex, name = nil)
    if ex.is_a?(FriendlyId::ReservedError)
      ZZAPIError.new("Sorry, \"#{name}\" is a reserved album name please try a different one")
    elsif ex.is_a?(FriendlyId::BlankError)
      ZZAPIError.new("Your album name must contain at least 1 letter or number")
    elsif ex.is_a?(ActiveModel::Errors)
      ZZAPIError.new(ex)
    else
      ex
    end
  end

  #
  # The zz_api album info method method.  Gets info about a single album owned by the
  # passe
  #
  # This is called as (GET):
  #
  # /zz_api/albums/:album_id
  #
  # You must have an album admin role as determined by the current logged in users rights.
  #
  #
  # Returns the album info in the following form:
  #
  # {
  #    :id => album_id,
  #    :name => album_name,
  #    :email => album.email,
  #    :user_name => album_user_name,
  #    :user_id => album_user_id,
  #    :album_path => album_pretty_path(album_user_name, album_friendly_id),
  #    :profile_album => is_profile_album,
  #    :c_url =>  cover url,
  #    :cover_id => cover_id,
  #    :cover_base => cover_base same as a photo returned where cover_sizes are the substitution sizes,
  #    :cover_sizes => cover_sizes,
  #    :photos_count => album.photos_count,
  #    :photos_ready_count => album.photos_ready_count,
  #    :cache_version => album.cache_version_key,
  #    :updated_at => album.updated_at.to_i,
  #    :cover_date => cover_date.to_i,
  #    :my_role => album.my_role, # valid values are viewer, contributor, admin - if null and you are the owner then Admin
  #    :privacy => album.privacy,
  #    :all_can_contrib => true if everyone can contribute,
  #    :who_can_download => who can download
  #    :who_can_upload => who can upload
  #    :who_can_buy => who can buy
  #    :stream_to_twitter => stream to twitter
  #    :stream_to_facebook => stream to facebook
  #    :stream_to_email => stream to email
  # }
  #
  def zz_api_album_info
    return unless require_user && require_album && require_album_admin_role
    zz_api do
      # build the result
      @album.as_hash
    end
  end

  # update an album
  #
  # The zz_api update album method.  Updates the specified album.
  #
  # This is called as (PUT):
  #
  # /zz_api/albums/:album_id
  #
  # You must have an album admin role as determined by the current logged in users rights.
  #
  # the expected parameters are (items marked with * are the defaults):
  #
  # {
  # :name => the album name
  # :privacy => the album privacy can be (public*, hidden, password)
  # :cover_photo_id => the optional cover photo id
  # :who_can_download => who is allowed to download (everyone*,contributors,owner)
  # :who_can_upload => who is allowed to upload (everyone,contributors*)
  # :who_can_buy => who is allowed to buy (everyone*,contributors,owner)
  # :stream_to_twitter => true if you want to stream updates to twitter
  # :stream_to_facebook => true if you want to stream updates to facebook
  # :stream_to_email => stream to email
  # }
  #
  # Returns the modified album in the following form:
  # See zz_api_album_info for return values
  #
  def zz_api_update
    return unless require_user && require_album && require_album_admin_role
    zz_api do
      begin
        fields = filter_params(params, [:name, :privacy, :cover_photo_id, :who_can_upload, :who_can_download,
                                        :who_can_buy, :stream_to_twitter, :stream_to_facebook, :stream_to_email])
        if !@album.update_attributes( fields )
          # shows the first error, web client side currently doesn't deal with hash
          # once it does, can pass full error format by just passing ex directly inside
          # ZZAPIError
          raise ZZAPIError.new(@album.errors.first.second)
        end
      rescue ZZAPIError => ex
        raise ex                # don't convert to friendly if already a ZZAPIError
      rescue Exception => ex
        raise friendly_error(ex, fields[:name])
      end
      # build the result
      @album.as_hash
    end
  end

  # create a new album
  #
  # The zz_api create album method.  Creates a new album
  # tied to the current user.
  #
  # This is called as (POST):
  #
  # /zz_api/albums/create
  #
  # Where :user_id is derived from your current account session.
  #
  # the expected parameters are (items marked with * are the defaults):
  #
  # {
  # :name => the album name
  # :privacy => the album privacy can be (public*, hidden, password)
  # :who_can_download => who is allowed to download (everyone*,contributors,owner)
  # :who_can_upload => who is allowed to upload (everyone,contributors*)
  # :who_can_buy => who is allowed to buy (everyone*,contributors,owner)
  # :stream_to_twitter => true if you want to stream updates to twitter
  # :stream_to_facebook => true if you want to stream updates to facebook
  # :stream_to_email => stream to email
  # }
  #
  # Returns an album in the following form:
  # See zz_api_album_info for return values
  #
  def zz_api_create
    return unless require_user
    zz_api do
      begin
        fields = filter_params(params, [:name, :privacy, :who_can_upload, :who_can_download,
                                        :who_can_buy, :stream_to_twitter, :stream_to_facebook, :stream_to_email])
        fields[:user_id] = current_user.id
        album = GroupAlbum.new(fields)
        # treat as an error rather than auto rename when duplicate
        album.skip_duplicate_name_check = true
        unless album.save
          raise friendly_error(album.errors)
        end
      rescue Exception => ex
        raise friendly_error(ex, fields[:name])
      end
      # build the result
      album.as_hash
    end
  end

  # return the sharing info for the given album
  #
  # This is called as (GET):
  #
  # /zz_api/albums/:album_id/sharing_edit
  #
  # You must have an album admin role as determined by the current logged in users rights.
  #
  # Returns the sharing info in the following form:
  #
  # {
  #  :user => {
  #   :has_facebook_token => true if facebook token set up
  #   :has_twitter_token => true if twitter token set up
  #   },
  #   :album => standard album info see hash album,
  #   :group => [   # this should be replaced with members style, Do Not Use for iPhone, use :members
  #   {
  #     :id => group id,
  #     :user_id => id of the group owner
  #     :name => name of the group, or if the self group, the users primary email,
  #     :permission => contributor or viewer,
  #     :profile_photo_url => profile photo if self group
  #   }
  #   ...
  #   ],
  #   :members => [
  #     hash of group info with permission attribute added (contributor or viewer or admin)
  #     see groups zz_api_info for detailed contents, admin cannot be currently set but can be returned
  #   ...
  #   ]
  #   :share => {
  #        :facebook => {
  #           :message => default message
  #           :title => title,
  #           :url => url back to the album,
  #           :description => post description,
  #           :photo => link to cover photo or nil
  #        },
  #        :twitter => {
  #            :message => default message
  #        }
  # }
  #
  def zz_api_sharing_edit
    return unless require_user && require_album && require_album_admin_role
    zz_api do
      hash = {
          :user => {
            :has_facebook_token => current_user.identity_for_facebook.has_credentials?,
            :has_twitter_token => current_user.identity_for_twitter.has_credentials?
          },
          :album => @album.as_hash,
          :group => get_flat_sharing_members,   #TODO change web client to use group form and get rid of this
          :members => get_sharing_members,      # this is the new form, get rid of above when web ui supports this
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
    end
  end

  # change a group member from contributor to viewer
  # or vice-versa
  #
  # This is called as (POST):
  #
  # /zz_api/albums/:album_id/update_sharing_member
  #
  # You must have an album admin role as determined by the current logged in users rights.
  #
  # Returns current sharing members
  #
  # Input:
  #
  # {
  #   :member => {
  #     :id => group id to modify
  #     :permission => the role for this set of users contributor/viewer
  #   }
  # }
  #
  # Output:
  # See zz_api_sharing_members
  #
  def zz_api_update_sharing_member
    return unless require_user && require_album && require_album_admin_role
    zz_api do
      member = params[:member]
      group_id = member[:id].to_i

      if member[:permission] == AlbumACL::CONTRIBUTOR_ROLE.name
        @album.add_contributors(group_id)
      else
        @album.add_viewers(group_id)
      end

      get_sharing_members
    end
  end

  # remove a member from the acl
  #
  # This is called as (POST):
  #
  # /zz_api/albums/:album_id/delete_sharing_member
  #
  # You must have an album admin role as determined by the current logged in users rights.
  #
  # Returns current sharing members
  #
  # Input:
  #
  # {
  #   :member => {
  #     :id => group id to delete
  #   }
  # }
  #
  # Output:
  # See zz_api_sharing_members
  #
  def zz_api_delete_sharing_member
    return unless require_user && require_album && require_album_admin_role
    zz_api do
      group_id = params[:member][:id].to_i
      @album.remove_from_acl(group_id)

      get_sharing_members
    end
  end


  # Add members to the share
  #
  # This is called as (POST):
  #
  # /zz_api/albums/:album_id/add_sharing_members
  #
  # You must have an album admin role as determined by the current logged in users rights.
  #
  # Returns the sharing members as in sharing members.
  #
  # Input:
  #
  # {
  #   :emails => [...] an array of emails to add
  #   :group_ids => [...] optional array of group ids to add (must belong to this user or be wrapped users)
  #   :message => the message to send (set to nil if you don't want a message)
  #   :permission => the role for this set of users contributor/viewer
  # }
  #
  # Output will differ based on if you are passing in group_ids or not.  If you set
  # the group_id attribute even if it is an empty array we use the groups info model
  # to return the results.
  #
  # If groups_id is missing, we assume backwards compatability
  # mode and return results the form:
  # [
  # {
  #      :id => group_id,
  #      :name => name,
  #      :permission => permission,
  #      :profile_photo_url => profile_photo
  #  }
  #  ...
  #  ]
  #
  # if group_ids is set indicating new api style we return the form as in zz_api_sharing_members api call
  # as:
  # [
  #   {
  #     groups api info attributes for each group as in zz_api_info method of groups controller
  #     :permission => 'contributor' or 'viewer' or 'admin'    # this attribute is added in to each group
  #   }
  # ...
  # ]
  #
  #
  # On Error:
  # If we have a list validation error with either the emails or group_ids we collect the items that were
  # in error into a list for each type and raise an exception. The exception will be returned to the client
  # as json in the standard error format.  The code will be INVALID_LIST_ARGS (1001) and the
  # result part of the error will contain:
  #
  # {
  #   :emails => [
  #     {
  #       :index => the index in the corresponding input list location,
  #       :token => the invalid email,
  #       :error => an error string
  #     }
  #     ...
  #   ],
  #   :group_ids => [
  #     {
  #       :index => the index in the corresponding input list location,
  #       :token => the missing group_id,
  #       :error => an error string, may be blank
  #     }
  #     ...
  #   ]
  # }
  #
  def zz_api_add_sharing_members
    return unless require_user && require_album && require_album_admin_role

    zz_api do
      emails, email_errors, addresses = ZZ::EmailValidator.validate_email_list(params[:emails])

      # grab any group ids and get the allowed ones
      group_ids = params[:group_ids]
      if group_ids
        found_group_ids = Group.allowed_group_ids(current_user.id, group_ids)
        missing_group_ids = ZZAPIInvalidListError.build_missing_list(group_ids, Set.new(found_group_ids))
        group_ids = found_group_ids

        # we only generate the error if using version of api where the groups attr was set, can be empty
        # todo web ui should also operate with this list at some point
        unless missing_group_ids.empty? && email_errors.empty?
          # got at least one error, so raise the exception
          raise ZZAPIInvalidListError.new({:group_ids => missing_group_ids, :emails => email_errors})
        end
      else
        group_ids = []
      end

      # convert emails to user_ids, creating automatic users if need be
      users, user_id_to_email = User.convert_to_users(addresses, current_user, true)

      # now append all of the users groups to the group_ids
      group_ids += users.map(&:my_group_id)

      # determine who needs to get emails - only those users
      # that did not already have this role or higher should
      # get the emails
      if params[:permission] == AlbumACL::CONTRIBUTOR_ROLE.name
        type = Share::TYPE_CONTRIBUTOR_INVITE
        # grant the new role and return a list of only the affected users
        affected_user_ids = @album.add_contributors(group_ids, true)
      else
        type = Share::TYPE_VIEWER_INVITE
        affected_user_ids = @album.add_viewers(group_ids, true)
      end

      # determine the set of emails to send if any
      if affected_user_ids.empty? == false
        users = User.select('id, email').where(:id => affected_user_ids).all
        emails = users.map(&:email)

        message = params[:message]
        if message
          # send a share message
          Share.create!(    :user =>         current_user,
                            :subject =>     @album,
                            :subject_url => album_pretty_url(@album),
                            :service =>     Share::SERVICE_EMAIL,
                            :recipients =>  emails,
                            :share_type =>  type,
                            :message    =>  message)

          zza.track_event('album.share.email')
        end
      end

      if params[:group_ids].nil?
        #todo old form, the web ui should be changed to use new
        #model so we can get rid of this
        members = get_flat_sharing_members
      else
        members = get_sharing_members
      end

      members
    end
  end

  # return the sharing members for the given album
  #
  # This is called as (GET):
  #
  # /zz_api/albums/:album_id/sharing_members
  #
  # You must have an album admin role as determined by the current logged in users rights.
  #
  # Returns the sharing info in the following form:
  #
  # [
  #   {
  #     groups api info attributes for each group as in zz_api_info method of groups controller
  #     :permission => 'contributor' or 'viewer' or 'admin'    # this attribute is added in to each group
  #   }
  # ...
  # ]
  #
  def zz_api_sharing_members
    return unless require_user && require_album && require_album_admin_role
    zz_api do
      get_sharing_members
    end
  end


  def import_all
    return unless require_user
    add_javascript_action( 'show_import_all_dialog' )
    redirect_to user_pretty_url(current_user)
  end


  # This is effectively the users homepage
  def index
    return unless require_nothing
    begin
      @user = User.find_full_user!(params[:user_id])
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
    @is_homepage_view = true
  end


  # Return the album meta data for a given user. The albums returned are split
  # across the various types such as liked albums, invited albums, my albums.
  #
  # This is called as (GET):
  #
  # /zz_api/users/:user_id/albums
  #
  # The data returned depends on who is logged in and what users is being requested.
  # If you are logged in and requesting data for yourself you will get all of your
  # private data returned.  If you are asking about a different user, you will see
  # that users public info.
  #
  # Returns the album meta data in the following form:
  #
  # {
  #    :user_id                        => user id this data belongs to,
  #    :logged_in_user_id              => the id of the user that requested this data or nil if not logged in
  #    :public                         => true if viewing public data
  #    :my_albums                      => the version string for my albums,
  #    :my_albums_path                 => the path to my albums
  #    :liked_albums                   => the version string to the liked albums
  #    :liked_albums_path              => path to the liked albums
  #    :liked_users_albums             => version string to like users albums
  #    :liked_users_albums_path        => path the public albums of the liked users combined
  #    :session_user_liked_albums      => version string,
  #    :session_user_liked_albums_path => the liked albums path for the logged in user,
  #    :invited_albums                 => version string,
  #    :invited_albums_path            => path to invited albums,
  #    :session_user_invited_albums      => version string,
  #    :session_user_invited_albums_path => path to the logged in users invited albums
  # }
  #
  def zz_api_albums()
    return unless require_nothing
    zz_api do
      user = User.find(params[:user_id])

      get_albums(user, true)
      loader = @loader
      session_loader = @session_loader
      if !session_loader.nil?
        session_liked_users_albums = session_loader.liked_users_album_loader.current_version_key
        session_liked_users_albums_link = zz_api_liked_users_albums_link(session_loader)
        session_invited_albums = session_loader.invited_album_loader.current_version_key
        session_invited_albums_link = zz_api_invited_albums_link(session_loader)
      else
        session_liked_users_albums = nil
        session_liked_users_albums_link = nil
        session_invited_albums = nil
        session_invited_albums_link = nil
      end

      album_meta = {
        :user_id                        => loader.user_id,
        :logged_in_user_id              => current_user ? current_user.id : nil,
        :public                         => loader.public,
        :my_albums                      => loader.my_album_loader.current_version_key,
        :my_albums_path                 => zz_api_my_albums_link(loader),
        :liked_albums                   => loader.liked_album_loader.current_version_key,
        :liked_albums_path              => zz_api_liked_albums_link(loader),
        :liked_users_albums             => loader.liked_users_album_loader.current_version_key,
        :liked_users_albums_path        => zz_api_liked_users_albums_link(loader),
        :session_user_liked_albums      => session_liked_users_albums,
        :session_user_liked_albums_path => session_liked_users_albums_link,
        :invited_albums                 => loader.invited_album_loader.current_version_key,
        :invited_albums_path            => zz_api_invited_albums_link(loader),
        :session_user_invited_albums      => session_invited_albums,
        :session_user_invited_albums_path => session_invited_albums_link
      }
    end
  end

  # invalidate the current cache for this user - essentially a forced cache flush version change
  def invalidate_cache
    return unless require_same_user_json
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

  def zz_api_my_albums_link(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.my_album_loader.current_version_key
    url = loader.public ? zz_api_my_albums_public_path(loader.user_id) : zz_api_my_albums_path(loader.user_id)
    url << "?ver=#{ver}"
  end

  def liked_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.liked_album_loader.current_version_key
    url = loader.public ? liked_albums_public_json_path(loader.user_id) : liked_albums_json_path(loader.user_id)
    url << "?ver=#{ver}"
  end

  def zz_api_liked_albums_link(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.liked_album_loader.current_version_key
    url = loader.public ? zz_api_liked_albums_public_path(loader.user_id) : zz_api_liked_albums_path(loader.user_id)
    url << "?ver=#{ver}"
  end

  def liked_users_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.liked_users_album_loader.current_version_key
    liked_users_public_albums_json_path(loader.user_id) + "?ver=#{ver}"
  end

  def zz_api_liked_users_albums_link(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.liked_users_album_loader.current_version_key
    zz_api_liked_users_public_albums_path(loader.user_id) + "?ver=#{ver}"
  end

  def invited_albums_path(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.invited_album_loader.current_version_key
    invited_albums_json_path(loader.user_id) + "?ver=#{ver}"
  end

  def zz_api_invited_albums_link(loader, force_zero_ver = false)
    ver = force_zero_ver ? 0 : loader.invited_album_loader.current_version_key
    zz_api_invited_albums_path(loader.user_id) + "?ver=#{ver}"
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
    return unless require_same_user_json
    my_albums_json_common(false)
  end

  def zz_api_my_albums
    return unless require_same_user_json
    zz_api_self_render do
      my_albums_json_common(false)
    end
  end

# fetch public albums for a given user
  def my_albums_public_json
    return unless require_nothing
    my_albums_json_common(true)
  end

  def zz_api_my_albums_public
    return unless require_nothing
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
    return unless require_same_user_json
    liked_albums_json_common(false)
  end

  def zz_api_liked_albums
    return unless require_same_user_json
    zz_api_self_render do
      liked_albums_json_common(false)
    end
  end

# fetch the albums that a given user likes
  def liked_albums_public_json
    return unless require_nothing
    liked_albums_json_common(true)
  end

  def zz_api_liked_albums_public
    return unless require_nothing
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
    return unless require_same_user_json
    invited_albums_json_common
  end

  def zz_api_invited_albums
    return unless require_same_user_json
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
    return unless require_nothing
    liked_users_public_albums_json_common
  end

  def zz_api_liked_users_public_albums
    return unless require_nothing
    zz_api_self_render do
      liked_users_public_albums_json_common
    end
  end

#deletes an album
#@album is set by require_album before_filter
  def destroy
    return unless require_user && require_album && require_album_admin_role
    # Album is found when the before filter calls authorized user
    if @album.destroy
      render :json => "Album deleted" and return
    else
      render :json => @album.errors, :status=>500 and return
    end
  end

  #
  # The zz_api album destroy method.  Deletes the album and all photos within.
  #
  # This is called as (DELETE):
  #
  # /zz_api/albums/:album_id
  #
  # You must have an album admin role as determined by the current logged in users rights.
  #
  #
  # Returns nothing.
  #
  def zz_api_destroy
    return unless require_user && require_album && require_album_admin_role
    zz_api do
      # Album is found when the before filter calls authorized user
      if @album.destroy == false
        raise ZZAPIError.new(@album.errors.full_messages, 500)
      end
      nil # nothing to return
    end
  end

#closes the current batch
# we also have a watchdog sweeper that will
# close batches with no new add activity after a 5 minute window
  def close_batch
    return unless require_user && require_album && require_album_contributor_role
    album_id = @album.id
    if album_id
      UploadBatch.close_batch( current_user.id, album_id)
    end
    render :nothing => true
  end

  # close a batch
  #
  # Closes the batch specified by the :album_id.
  #
  # This is called as (PUT):
  #
  # /zz_api/albums/:album_id/close_batch
  #
  # Where :album_id is the album you want to close.
  #
  #
  # You must be logged in and have album contributor privileges to close the batch.
  #
  # Returns an empty hash
  #
  def zz_api_close_batch
    return unless require_user && require_album && require_album_contributor_role
    zz_api do
      album_id = @album.id
      if album_id
        # get it but don't create it if doesn't exist
        current_batch = UploadBatch.get_current_and_touch(current_user.id, album_id, false)
        if current_batch
          current_batch.close_immediate
        end
      end
      # just an empty result
      {}
    end
  end

# Receives and processes a user's request for access into a password protected album
  def request_access
    return unless require_user && require_album
    if params[:access_type ] && params[:access_type] == AlbumACL::CONTRIBUTOR_ROLE.name
      ZZ::Async::Email.enqueue( :request_contributor, current_user.id, @album.id,  params[:message] )
    else
      ZZ::Async::Email.enqueue( :request_access, current_user.id, @album.id,  params[:message] )
    end
    head :ok and return
  end

  # shared permissions check for both download and download_direct
  def download_security_check
    return false unless require_album

    unless  @album.can_user_download?( current_user )
      flash.now[:error] = "Only Authorized Album Group Members can download albums"
      if request.xhr?
        head :status => 401
      else
        render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      end
      return false
    end
    return true
  end

  # Due to issues with Amazons ELB dropping connections and
  # in some cases dropping the Content-Length header for large requests
  # we bypass it by doing a redirect to our direct DNS name
  # this will bypass the ELB and let the client call
  # back into us directly.
  def download
    return unless download_security_check

    # build the single access key if we have a current user
    #TODO move this to auth helpers
    key = ''
    if current_user
      key = "?zzapi_key=#{current_user.single_access_token}"
    end

    zz = ZZDeployEnvironment.env.zz
    redirect_to "http://#{zz[:public_hostname]}#{download_direct_album_path(@album)}#{key}"
  end

  # @album is set by require_album before_filter
  # prepare to download an on the fly zip of the photos
  # we return.  The heavy lifting is handled by the mod_zip
  # plugin to nginx, so our job is to put together the list
  # of all photos that have been uploaded to amazon
  def download_direct
    return unless download_security_check

    # Walk the list of all photos and build up the zip_download hash that tells
    # us which files to download and crc32 and filesize info for each file.
    # Since we just added crc32 some files don't have it so it is permissible for it
    # to be just nil.  When we perform the next full photos resize sweep we can compute
    # and add it to those that are missing.
    #
    # This call passes the real work to eventmachine in to form:
    # /proxy_eventmachine/zip_download?json_path=/data/tmp/json_ipc/62845.1323732431.61478.6057566634.json
    # It must also set the X-Accel-Redirect header with the above uri to cause nginx to internally proxy
    # to eventmachine.  We have a helper method in the util class that will take a hash, add in the appropriate
    # user info, save the local ipc file and set up the header.
    #
    proxy_data = {
        :album_name => @album.name,
        :album_id => @album.id
    }
    urls = []
    i = 0
    dup_filter = Set.new
    @album.photos.each do |photo|
      i += 1
      image_path = photo.image_path
      image_file_size = photo.image_file_size.nil? ? nil : photo.image_file_size.to_i
      if (photo.ready? || photo.loaded?) && image_path
        full_name = photo.file_name_with_extension(dup_filter, i)
        escaped_url = URI::escape(image_path.to_s)
        uri = URI.parse(escaped_url)
        query = uri.query.blank? ? '' : "?#{uri.query}"
        crc32 = photo.crc32.nil? ? nil : photo.crc32.to_i
        capture_date = photo.capture_date
        local_date = nil
        if capture_date
          # need to treat as a local time since database time is UTC but original stored in local time
          local_date = capture_date.to_i - capture_date.utc_offset
        end
        url_info = {
            :url => "http://#{uri.host}#{uri.path}#{query}",
            :size => image_file_size,
            :crc32 => crc32,
            :create_date => local_date || photo.created_at.to_i,
            :filename => full_name
        }
        urls << url_info
      end
    end
    proxy_data[:urls] = urls

    if urls.empty?
      flash[:error]="Album has no photos ready for download"
      head :not_found and return
    else
      zza.track_event("albums.download.full")
      Rails.logger.debug("Full album download: #{@album.name}")
      if params[:test]
        files = JSON.pretty_generate(proxy_data)
        response.headers['Content-Disposition'] = "attachment; filename=testfile.txt"
        render :content_type => "application/octet-stream", :text => files
      else
        prepare_proxy_eventmachine('zip_download', proxy_data)
        render :nothing => true
      end
      return
    end
  end

  # displays the add photos dialog if the current user is allowed
  def add_photos
    return unless require_album(true) && require_album_contributor_role
    add_javascript_action( 'show_add_photos_dialog' )
    redirect_to album_pretty_url( @album ) and return
  end

  # displays the add photos dialog if the current user is allowed
  def wizard
    return unless require_user && require_album(true) && require_album_admin_role
    raise Exception.new("Wizard Step Must Be Specified") unless params[:step ]
    args ={}
    args[:step]  = params[:step]
    args[:email] = params[:email] if params[:email]
    add_javascript_action( 'show_album_wizard', args )
    redirect_to album_pretty_url( @album ) and return
  end

  # set latest photo as cover
  def set_latest_cover
    return unless require_any_user && require_album #&& require_album_admin_role #TODO: need to fix this, user is blank here

    @album.cover = @album.photos.last
    render :json => {:id => @album.cover.id, :t_url => @album.cover.thumb_url }, :status => 200, :layout => false and return
  end

  private

  # fetches the album paths, this is common code shared
  # between zz_api and normal apis
  # returns @loader, and @session_loader context which
  # can be used to create the specific form of data that
  # each type of call wants
  def get_albums(user, zz_api)
    # determine if we should be fetching the view based on public or private data
    user_is_me = current_user?(user)
    private_view = user_is_me || (current_user && current_user.support_hero?)
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
    if public && current_user
      # ok, we have a valid session user and we are viewing somebody else so pull in our liked_albums
      session_loader = Cache::Album::Manager.shared.make_loader(current_user, false)
      session_loader.pre_fetch_albums
    end

    @loader = loader
    @session_loader = session_loader
  end

  # return the hash for a single member
  # probably will want to unify this with
  # how we return group members but for compatibility with the web ui
  # we keep it in the current form
  #todo Once Jeremy begins work on changing this, lets switch to the new api
  def get_sharing_member(user, permission)
    if user.automatic?
      real_name = user.name(false)   # no anonymous conversion
      name = real_name.blank? ? user.email : user.formatted_email
      profile_photo = nil
    else
      name = user.formatted_email
      profile_photo = user.profile_photo_url(false)
    end

    hash = {
        :id => user.my_group_id,
        :name => name,
        :permission => permission,
        :profile_photo_url => profile_photo
    }
  end

  # For the web ui until we update it we return
  # the flattened list of sharing members as all users
  def get_flat_sharing_members
    roles = @album.acl.get_users_and_roles
    contributors = roles[AlbumACL::CONTRIBUTOR_ROLE]
    viewers = roles[AlbumACL::VIEWER_ROLE]

    # do efficient single query to fetch all groups at once
    # and create a user_id => user hash for lookup
    all_ids = Array(contributors + viewers)
    users = User.where(:id => all_ids).includes(:profile_album).all
    users = users.sort do |a,b|
      a_name = a.name_sort_value
      b_name = b.name_sort_value
      a_name.casecmp(b_name)
    end

    # now build the final output form with permissions added in
    members = []
    contributors = Set.new(contributors)  # as a set for efficient checks
    users.each do |user|
      permission = contributors.include?(user.id) ? AlbumACL::CONTRIBUTOR_ROLE.name : AlbumACL::VIEWER_ROLE.name
      members << get_sharing_member(user, permission)
    end

    members
  end

  # this form of sharing members returns all groups in the same form
  # as the groups controller zz_api method but also appends a :permission
  # attribute to each of the group hashes.  The permission will
  # be contributor or viewer
  #
  def get_sharing_members
    # fetch them all in a single query
    roles = @album.acl.get_groups_and_roles
    admins = roles[AlbumACL::ADMIN_ROLE]
    contributors = roles[AlbumACL::CONTRIBUTOR_ROLE]
    viewers = roles[AlbumACL::VIEWER_ROLE]

    # do efficient single query to fetch all groups at once
    # and create a user_id => user hash for lookup
    all_group_ids = Array(contributors + viewers + admins)
    groups = Group.where(:id => all_group_ids).includes(:wrapped_user => :profile_album).all
    # now sort them
    groups = Group.sort(groups)

    # now build the final output form with permissions added in
    members = []
    contributors = Set.new(contributors)  # as a set for efficient checks
    admins = Set.new(admins)  # as a set for efficient checks
    groups.each do |group|
      group_id = group.id
      if admins.include?(group_id)
        permission = AlbumACL::ADMIN_ROLE.name
      elsif contributors.include?(group_id)
        permission = AlbumACL::CONTRIBUTOR_ROLE.name
      else
        permission = AlbumACL::VIEWER_ROLE.name
      end
      members << group.as_hash({:permission => permission})
    end

    members
  end

end
