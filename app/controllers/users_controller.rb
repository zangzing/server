class UsersController < ApplicationController
  ssl_required :join, :finish_profile, :create, :edit_password, :update_password,
               :zz_api_login_or_create, :zz_api_login_create_finish
  ssl_allowed :validate_email, :validate_username

  skip_before_filter :verify_authenticity_token, :only=>[:create]

  def join
    # URL Cleaning cycle
    if params[:return_to] || params[:email] || params[:message]
      session[:return_to] = params[:return_to] if params[:return_to]
      session[:message] = params[:message] if params[:message]
      flash.keep
      unless current_user
        session[:email] = params[:email] if params[:email]
        redirect_to join_url and return
      end
    end

    # first see if an automatic user that has completed step 1
    if any_current_user && any_current_user.completed_step == 1
      redirect_to finish_profile_url
      return
    end

    # now see if we have a full user in which case
    # we don't want to join
    if current_user
      redirect_back_or_default user_pretty_url(current_user)
      return
    end
    
    if session[:message]
      @message = session[:message]  
      session.delete(:message)
    end

    if session[:email]
      @new_user = User.new(:email => session[:email] )
      session.delete(:email)
    else
      @new_user = User.new
    end
  end

  # NOTE, put common logic in create_user_shared but do NOT put
  # web specific logic there, put the specific web logic here.
  def create
    if current_user
        flash[:notice] = "You are currently logged in as #{current_user.username}. Please log out before creating a new account."
         add_javascript_action( 'show_message_dialog',  {:message => flash[:notice]})
         redirect_back_or_default user_pretty_url(current_user)
        return
    end

    user_info = params[:user]

    success = create_user_shared(user_info, params[:follow_user_id], current_tracking_token)

    if success
      if @new_user.active
        flash[:success] = "Welcome to ZangZing!"
        add_javascript_action('show_welcome_dialog') unless( session[:return_to] )
        redirect_back_or_default user_pretty_url( @new_user )
        return
      else
        redirect_to inactive_url
        return
      end
    end

    render :action => :join, :layout => false
  end

  def finish_profile
    if any_current_user && any_current_user.completed_step == 1
      @user = any_current_user
      render :layout => 'plain'
    else
      redirect_to join_url
    end
  end
  
  def show
    @user = User.find(params[:id])
    redirect_to user_pretty_url(@user )
  end

  def edit
    return unless require_same_user
    @user = current_user
  end

  def edit_password
    @user = current_user
  end

  def update_password
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your Password Has Been Changed."
      redirect_to user_pretty_url(@user)
    else
      render :action => :edit_password
    end
  end

  def update
    return unless require_same_user
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your Profile Has Been Updated."
      redirect_to user_path(@user)
    else
#      flash[:error] = @user.errors
      render :action => :edit
    end
  end

  def validate_email
    if params[:user] && params[:user][:email]
      render :json => email_available?(params[:user][:email]) and return
    else
      render :json => true # Missing or nil so technically it is available
    end
  end

  def validate_username
    if params[:user] && params[:user][:username]
      render :json => username_available?(params[:user][:username])
    else
      render :json => true # Missing or nil so technically it is available
    end
  end

  # Checks availability of username and/or email.
  #
  # This is called as (POST):
  #
  # /zz_api/users/available
  #
  # Does not require a current logged in user.  If you are the logged in user
  # and pass your own name the call will act as if the username or email is available.
  #
  # Input:
  #
  # {
  #   :email => optional email to check,
  #   :username => optional username to check
  # }
  #
  # When email or username is not present or nil, we will return true in the corresponding
  # result value for that item.
  #
  # Returns the validation info.
  #
  # {
  #   :email_available => true if email is available or nil, false if taken
  #   :username_available => true if username is available or nil, false if taken
  # }
  def zz_api_available
    return unless require_nothing

    zz_api do
      result = {}
      result[:email_available] = email_available?(params[:email])
      result[:username_available] = username_available?(params[:username])
      result
    end
  end

  # Gets info about a single user.
  #
  # This is called as (GET):
  #
  # /zz_api/users/:user_id/info
  #
  # Does not require a current logged in user, used to request info about any user.
  #
  # Input:
  #
  # Returns the user info.
  #
  # {
  #        :id => users id,
  #        :my_group_id => the group that wraps just this user,
  #        :username => user name,
  #        :profile_photo_url => the url to the profile photo, nil if none,
  #        :profile_album_id => the profile album id, nil if none
  #        :first_name => first_name,
  #        :last_name => last_name,
  #        :email => email for this user (this will only be present for automatic users and in cases where you looked up the user via email, or the user is you)
  #        :automatic => true if an automatic user (one that has not created an account)
  #        :auto_by_contact => true if automatic user and was created simply by referencing (i.e. we added automatic as result of group or permission operation)
  #                            if automatic is set and this is false it means we have a user that has actually sent a photo in on that address
  # }
  def zz_api_user_info
    return unless require_nothing

    zz_api do
      user_id = params[:user_id]
      user = User.find(user_id)
      id_to_email = user == current_user ? {user_id => user.email} : nil
      user_info = user.basic_user_info_hash(id_to_email)
    end
  end

  # Gets info about the current logged in user.
  #
  # This is called as (GET):
  #
  # /zz_api/users/current_user_info
  #
  # Requires a logged in user (automatic or full).
  #
  # Input:
  #
  # Returns the user info.
  #
  # {
  #    see api_user_info for return values but also adds:
  #
  #   :has_facebook_token => true if facebook token set up
  #   :has_twitter_token => true if twitter token set up
  # }
  def zz_api_current_user_info
    return unless require_any_user

    zz_api do
      user = any_current_user
      user_info = user.basic_user_info_hash
      user_info[:email] = user.email
      user_info[:has_facebook_token] = current_user.identity_for_facebook.has_credentials?
      user_info[:has_twitter_token] = current_user.identity_for_twitter.has_credentials?
      user_info
    end
  end

  # Finds or creates users.
  #
  # This will find existing users.  It will also create users from the emails
  # when the create flag is true for any that are not found already.
  #
  # Finding by user_ids and user_names
  # do not auto create users, only via email.  For emails, if the user is found
  # we return it with the additional email context added to that user object.  If the
  # email user is not found we create a new automatic users.  You can specify the
  # First, Last name to user by specifying the fully qualified email such as:
  # Joe Smith <joe_smith@somewhere.com>.  This will result in a user with the first name
  # set to Joe, and last name set to Smith, email set to joe_smith@somewhere.com
  #
  # This is called as (POST):
  #
  # /zz_api/users/find_or_create
  #
  # This call requires the caller to be logged in.
  #
  # Input:
  # {
  #   :user_ids => [ array of user ids to find ],
  #   :user_names => [ array of user names to find ],
  #   :create => when true or not set tells us to create users from missing emails, false acts as find only
  #   :emails => [ array of emails to find or create ],
  # }
  #
  #
  # Returns:
  # fetches and returns all users found or created in the form
  #
  # {
  #   :users => [
  #     user_info_hash - the hash containing the user info as returned in the user info call
  #     ...
  #   ]
  #   :not_found => {
  #     :emails => [
  #       {
  #         :index => the index in the corresponding input list location,
  #         :token => the missing email,
  #         :error => an error string, may be blank
  #       }
  #       ...
  #     ],
  #     :user_ids => [
  #       {
  #         :index => the index in the corresponding input list location,
  #         :token => the missing user_id,
  #         :error => an error string, may be blank
  #       }
  #       ...
  #     ],
  #     :user_names => [
  #       {
  #         :index => the index in the corresponding input list location,
  #         :token => the missing user name,
  #         :error => an error string, may be blank
  #       }
  #       ...
  #     ]
  #   }
  # }
  #
  # Errors:
  # If we have a list validation error with the emails we collect the items that were
  # in error into a list for each type and raise an exception. The exception will be returned to the client
  # as json in the standard error format.  The code will be INVALID_LIST_ARGS (1001) and the
  # message part of the error will contain:
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
  # }
  # NOTE that we do not consider a not found user_name or user_id to be an error since this is a find
  # call but instead return as part of the normal results.
  def zz_api_find_or_create
    return unless require_user

    zz_api do
      orig_emails = params[:emails]
      user_ids, user_id_errors = User.validate_user_ids(params[:user_ids])
      ids_by_name, user_name_errors = User.validate_user_names(params[:user_names])
      user_ids += ids_by_name
      emails, email_errors, addresses = ZZ::EmailValidator.validate_email_list(orig_emails)

      unless email_errors.empty?
        # at least one error so raise exception
        raise ZZAPIInvalidListError.new({:emails => email_errors})
      end

      # the :create flag defaults to true if missing
      should_create = params[:create].nil? || params[:create]

      converted_users, user_id_to_email = User.convert_to_users(addresses, current_user, should_create)
      converted_ids = converted_users.map(&:id)
      user_ids += converted_ids

      missing_emails = []
      if should_create == false
        found_emails = Set.new
        converted_users.each { |user| found_emails.add(user.email.downcase) }
        index = 0
        # walk the parsed emails
        emails.each do |email|
          # if missing use the original full email field not the parsed one to report the error
          missing_emails << ZZAPIInvalidListError.build_missing_item(index, orig_emails[index]) unless found_emails.include?(email.downcase)
          index += 1
        end
      end

      members = preload_users(user_ids)
      users = User.as_array(members, user_id_to_email)
      hash = {
          :users => users,
          :not_found => {
              :emails => missing_emails,
              :user_ids => user_id_errors,
              :user_names => user_name_errors
          }
      }
      hash
    end
  end

  # Create user step one or login.  Used in two step user creation.
  #
  # When creating a new user, we can spread the creation across two
  # steps.  The first step is to pass the email and password.
  # We check to see if the email already exists.  If it does and
  # matches a full user, we attempt login with the password given.
  # If the password is not correct we return an error.
  #
  # If the matched user via the email is an automatic user, we
  # set the password given and set the completed_step to 1 in the user
  # object.
  #
  # If the email matches no user, we create an auto_by_contact user
  # with the given password and set the step to 1.
  #
  # If the call is successful we set up and return the user_credentials
  # cookie.  This way, if a user visits the home page, we can redirect
  # to create step 2 to let them finish the sign up.
  #
  # As a alternative to logging in or creating an account with email
  # and password, you can instead use service and credentials.  The service
  # currently can only be facebook.  The credentials represent the API
  # token that the server then uses to obtain your facebook info and log
  # you in or performs join phase one for the case where you want to create
  # an account.
  #
  # Also, we allow for the full user creation to happen in one step if you
  # provide all necessary params to do so.  You need email, name, username,
  # and password, and set the create flag to true.
  #
  # This is called as (POST - https):
  #
  # /zz_api/login_or_create
  #
  # This call requires the caller to not be logged in.
  #
  # Input:
  # {
  #   :email => the email to create or login with, can also be username if logging in,
  #   :password => password to create or login with,
  #   :name => optional username, set with name if you want to do the full create in one step
  #   :username => optional name, set with username if you want to do the full create in one step
  #   :follow_user_id => optional id of user to follow - only used if creating the full user right now,
  #   :tracking_token => optional tracking token used to determine who invited you, for session based
  #     api clients (i.e. the web ui) this will be picked up from the session - only used if creating
  #     the full user in one step, otherwise pass in step 2 if needed,
  #   :service => as an alternative to email and password, you can log in via a third party
  #     service such as facebook (facebook is the only service we currently support),
  #   :credentials => the third party service credentials (API Token),
  #   :create => if this flag is present and true, we will assume a user that was not found should be created
  # }
  #
  #
  # Returns:
  # the credentials and user rights.  If the user is an automatic user then you are not
  # fully logged in when this call returns since you must proceed to step 2 to finish the
  # account creation.  If the user is a normal user then you are logged in if no error
  # is returned.
  #
  # {
  #   :user_id => id of this user,
  #   :user_credentials => a string representing the user credentials, to use, set
  #       the user_credentials cookie to this value
  #   :completed_step => the completed step number (will be null when this step is done),
  #   :server => the host you are connected to
  #   :role => the system rights role for this user.  Can be one of
  #     the :available_roles such as:
  #     Admin,Hero,SuperModerator,Moderator,User
  #     The roles are shown from most access to least
  #     So, for example, if you need Moderator rights and you are an Admin
  #     you will be granted access.  On the other hand, if
  #     you are a User you will not be granted access.
  #   :available_roles => Ordered from most access to least lets you determine
  #     the available roles and their order
  #   :client_side_zza_events => ['event1', ...] an array of client side zza event strings that should
  #     be sent to zza by the client
  #   :zzv_id => token used to user identifier for tracking via mixpanel,
  #   :user => user info as returned in user_info call
  # }
  def zz_api_login_or_create
    return unless require_no_user

    zz_api do
      # see if we already have a full account that matches this email or username
      email = params[:email]
      password = params[:password]
      name = params[:name]
      username = params[:username]
      tracking_token = params[:tracking_token] || current_tracking_token

      # no user yet
      cred_user = nil

      service = params[:service]
      credentials = params[:credentials]
      if service
        raise ZZAPIError.new("Facebook is the only allowed service for login") unless ['facebook'].include?(service)
        raise ZZAPIError.new("You must specify credentials if logging in with a service") unless credentials
        cred_user, identity, service_user_id = find_user_from_facebook_identity(credentials)
      end

      # first try to login
      just_created = false
      create_user = !!params[:create]
      if password || cred_user.nil?
        user_session = UserSession.new(:email => email, :password => password)
      elsif cred_user
        user_session = UserSession.new(cred_user)
      else
        raise ZZAPIError.new("You cannot log in without valid credentials or username/password", 401)
      end
      if user_session.save
        user = user_session.user
        if user.automatic? && create_user == false
          raise ZZAPIError.new("You cannot log in with an account that is still joining", 401)
        end
        # ok, we are logged in
      elsif create_user == false
        # raise an error if we couldn't log in and not allowed to create
        raise ZZAPIError.new(user_session.errors.full_messages, 401)
      end

      may_create = (!user.nil? && user.automatic?) || user.nil?
      if may_create && name && username
        # auto or nil user and they passed everything needed to create
        user_info = {
            :name => name,
            :email => email,
            :username => username,
            :password => password,
        }
        success = create_user_shared(user_info, params[:follow_user_id], tracking_token)
        failed_create(user) unless success # raises an exception always
        user = @new_user
        just_created = true
      end

      if user.nil? && email.index('@')
        # not logged in, lets try to create an automatic user
        user = User.find_by_email(email)
        if user.nil?
          # make a new one since nobody has this email
          name = ''
          options = {
              :password => password,
              :completed_step => 1,
              :with_session => true
          }
          user = User.create_automatic(email, name, true, nil, options)
          just_created = true
        elsif user.automatic? == false
          user = nil  # found a real user but password was bad since we are here
        end
      end
      raise ZZAPIError.new(user_session.errors.full_messages, 401) if user.nil?

      # for an automatic user that already existed, always reset password and completed_step
      if user.automatic? && just_created == false
        # update the user info
        user.completed_step = 1
        user.reset_password = true
        user.password  = password
        user.password_confirmation = password
        user.save!
      end

      # if they passed in credentials update our identity info
      if credentials
        update_facebook_identity(user, credentials, service_user_id)
      end

      profile_album_id = user.profile_album_id   # has the side effect of creating the profile album if doesn't already exist
      user_credentials = user.persistence_token
      result = prepare_user_result(user, user_credentials)
      user_hash = result[:user]
      # hand set the profile_album_id since this is an automatic user
      # that normally does not get a profile album but here we create
      # one so fix up the hash
      user_hash[:profile_album_id] = profile_album_id
      result
    end
  end


  # Step two of the user creation process.
  #
  # To get to this step the user must have already specified an email
  # and password in step one and have set up the user_credentials for
  # this automatic user that is about to become a full user.
  #
  # If we get here for an existing full user, we fail the call.
  # If the user has not completed step one, we also fail the call.
  #
  # If the call is successful the user is logged in and ready to go with
  # the existing user_credentials they are using.
  #
  #
  # This is called as (POST - https):
  #
  # /zz_api/zz_api_login_create_finish
  #
  # This call requires the caller to be logged in with the user_credentials
  # returned in the first step.
  #
  # Input:
  # {
  #   :name => the full name to use - this is the friendly name such as Joe Smith,
  #   :username => the username that should be used,
  #   :password => optional password to reset,
  #   :follow_user_id => optional id of user to follow,
  #   :tracking_token => optional tracking token used to determine who invited you, for session based
  #     api clients (i.e. the web ui) this will be picked up from the session
  #   :profile_photo_url => option url to profile photo that we should set
  # }
  #
  #
  # Returns:
  # the credentials and user rights, you are logged in if this returns without error
  #
  # {
  #   :user_id => id of this user,
  #   :user_credentials => a string representing the user credentials, to use, set
  #       the user_credentials cookie to this value.  This will be nil if the user is not active.
  #   :completed_step => the completed step number (will be 1 when this step is done, or null if already created),
  #   :server => the host you are connected to
  #   :role => the system rights for this user, can be one of
  #     the :available_roles such as:
  #     Admin,Hero,SuperModerator,Moderator,User
  #     The roles are shown from most access to least
  #     So, for example, if you need Moderator rights and you are an Admin
  #     you will be granted access.  On the other hand, if
  #     you are a User you will not be granted access.
  #   :available_roles => Ordered from most access to least lets you determine
  #     the available roles and their order
  #   :client_side_zza_events => ['event1', ...] an array of client side zza event strings that should
  #     be recorded by the client
  #   :zzv_id => token used to user identifier for tracking via mixpanel,
  #   :user => user info as returned in user_info call
  # }
  def zz_api_login_create_finish
    return unless require_any_user

    zz_api do
      user = any_current_user
      raise ArgumentError.new("This account has already been created") unless user.automatic?
      raise ArgumentError.new("Attempting to create the user without previously setting email and password") unless user.completed_step == 1

      tracking_token = params[:tracking_token] || current_tracking_token
      profile_photo_url = params[:profile_photo_url]

      # now try to convert to a full user
      user_info = {
          :name => params[:name],
          :email => user.email,
          :username => params[:username],
          :password => params[:password],
      }
      success = create_user_shared(user_info, params[:follow_user_id], tracking_token)

      user = @new_user

      if success
        import_profile_photo(user, profile_photo_url) if profile_photo_url
        user_credentials = user.active? ? user.persistence_token : nil
        result = prepare_user_result(user, user_credentials)
      else
        failed_create(user)
      end
      result
    end
  end

  # log the user out
  #
  # This is called as (POST):
  #
  # /zz_api/logout
  #
  # expects a current logged in user
  #
  def zz_api_logout
    zz_api do
      current_user_session.destroy if any_current_user
      nil
    end
  end


  private

  # returns true if we have a valid user name
  # also returns true if username is nil
  def username_available?(username)
    if username
      if ReservedUserNames.is_reserved?(username)
        return false
      else
        user = User.find_by_username(username)
        return true if user.nil? || user == current_user || user.automatic?
      end
      return false
    end
    return true
  end

  # returns true if we have a valid email
  # also returns true if email is nil
  def email_available?(email)
    if email
      user = User.find_by_email(email)
      if user.nil? || user == current_user || user.automatic?
        return true
      else
        return false
      end
    end
    return true
  end


  # called when we failed to create a user
  def failed_create(user)
    raise ZZAPIError.new("Unable to create user", 401) if user.nil?
    raise ZZAPIError.new(user.errors.full_messages, 401) if user.errors.length > 0
    raise ZZAPIError.new("Unable to create user", 401)
  end

  # standard result form for login or create
  def prepare_user_result(user, user_credentials)
    role = get_users_role(user)
    user_hash = user.basic_user_info_hash
    # add in extra context
    user_hash[:email] = user.email
    result = {
        :user_credentials => user_credentials,
        :user_id =>  user.id,
        :username => user.username,
        :server => Server::Application.config.application_host,
        :role => role.name,
        :available_roles => SystemRightsACL.role_names,
        :client_side_zza_events => zza_client_events,
        :zzv_id => "placeholder until merge with Jeremy",
        :user => user_hash
    }
  end

  # efficient fetch of users and dependent data that will be loaded
  def preload_users(user_ids)
    users = User.where(:id => user_ids).includes(:profile_album).all
    albums = []
    users.each do |user|
      profile_album = user.profile_album
      albums << profile_album if profile_album
    end
    Album.fetch_bulk_covers(albums)
    # ok, we are pre-flighted with everything we need loaded now
    users
  end

  def admin_user
    redirect_to( root_path ) unless current_user.admin?
  end


  # see if this is a reserved username and if proper key has been passed
  # updates the user_info with the outcome, nil for bad, updated name otherwise
  def check_reserved_username user_info
    user_name = user_info[:username]
    checked_user_name = ReservedUserNames.verify_unlock_name(user_name)

    # if we get a nil checked_user_name it is because the name was reserved
    # and the unlock code was wrong.  We will pass the nil on to force an
    # error.
    user_info[:username] = checked_user_name

    return checked_user_name
  end

  def get_users_role(user)
    acl = SystemRightsACL.singleton
    role = acl.get_user_role(user.id)
    if role.nil?
      role = SystemRightsACL::USER_ROLE
      acl.add_user(user, role)
    end
    role
  end

  # start off the import process for a
  # profile photo
  def import_profile_photo(user, url)
    album = user.profile_album
    user_id = user.id
    album_id = album.id
    current_batch = UploadBatch.factory( user_id, album_id, false )
    photo = Photo.create(
            :id => Photo.get_next_id,
            :caption => 'My Profile Photo',
            :album_id => album_id,
            :user_id => user_id,
            :upload_batch_id => current_batch.id,
            :capture_date => Time.now,
            :source_guid => Photo.generate_source_guid(url),
            :source_thumb_url => url,
            :source_screen_url => url,
            :source => 'user_join'
    )
    ZZ::Async::GeneralImport.enqueue(photo.id,  url)
    user.profile_photo_id = photo.id
    current_batch.close_immediate
  end

  # common create user code shared between
  # web and zz_api, do not place any web ui
  # specific code here
  #
  # returns with
  # @user_session set up
  # @new_user
  # returns true if ok, false if failed
  def create_user_shared(user_info, follow_user_id, tracking_token)
    clear_buy_mode_cookie

    @user_session = UserSession.new

    # RESERVED NAMES
    # check username if in magic format
    checked_user_name = check_reserved_username(user_info)
    if checked_user_name.nil?
      @new_user = User.new()
      @new_user.set_single_error(:username, "You attempted to use a reserved user name without the proper key." )
      return false
    end

    # AUTOMATIC USERS
    #Check if user is an automatic user ( a contributor that has never logged in but has sent photos )
    @new_user = User.find_by_email( user_info[:email])
    if @new_user && @new_user.automatic?
      @new_user.convert_to_full_user(user_info[:name], user_info[:username], user_info[:password])
    else
      @new_user = User.new(user_info)
    end
    @new_user.reset_perishable_token
    @new_user.reset_single_access_token

    # SIGNUP CONTROL
    # new users are active by default
    if SystemSetting[:signup_control]
      @new_user.active = false
      @guest = Guest.find_by_email( user_info[:email] )
      if @guest
        if SystemSetting[:always_allow_beta_listers] && @guest.beta_lister?
          @new_user.active = true #always allow when beta-lister is set and user is beta_lister
          SystemSetting[:new_users_allowed] -= 1 if SystemSetting[:new_users_allowed]
        else
          if SystemSetting[:new_users_allowed] > 0
            # user allotment available
            if @guest.share?
              if SystemSetting[:allow_sharers]
                @new_user.active= true
                SystemSetting[:new_users_allowed] -= 1
              end
            else
              @new_user.active= true
              SystemSetting[:new_users_allowed] -= 1
            end
          end
        end
      end
    end

    # CREATE USER
    if @new_user.active

      # Save active user,authlogic creates a session to log user in when we save
      if @new_user.save
        prevent_session_fixation
        associate_order
        if @guest
          @guest.user_id = @new_user.id
          @guest.status = 'Active Account'
          @guest.save
        end

        if follow_user_id
          follow_user = User.find_by_id(follow_user_id)
          Like.add(@new_user.id, follow_user.id, Like::USER) if follow_user && !follow_user.automatic?
        end

        @new_user.deliver_welcome!
        send_zza_event_from_client('user.join')

        # process tracking token if there was one
        if tracking_token
          TrackedLink.handle_join(@new_user, tracking_token)
        end

        # process any invitations tied to this email address or tracking token
        invitation = Invitation.process_invitations_for_new_user(@new_user, tracking_token)

        # send zza events
        if invitation
          send_zza_event_from_client('invitation.join')
          send_zza_event_from_client(invitation.tracked_link.join_event_name)
        end

        return true
      end
    else
      # Saving without session maintenance to skip
      # auto-login which can't happen here because
      # the User has not yet been activated
      if @new_user.save_without_session_maintenance
        prevent_session_fixation
        if @guest
          @guest.user_id = @new_user.id
          @guest.status = 'Inactive'
          @guest.save
        end
        send_zza_event_from_client('user.join')
        return true
      end
    end
    return false
  end

  # finds the facebook identity for the given credentials
  # returns
  # user, identity, service_user_id
  # raises exception if we can't get the data we need from the credentials
  def find_user_from_facebook_identity(credentials)
    user = nil
    graph = HyperGraph.new(credentials)
    me = FacebookIdentity.get_me(graph)
    raise ZZAPIError.new("Your facebook credentials are not valid") unless me
    service_user_id = me[:id]
    raise ZZAPIError.new("Your facebook credentials are not enabled to return user id") unless service_user_id

    # see if we already have a user tied to this set of credentials
    identity = FacebookIdentity.find_by_service_user_id(service_user_id)
    if identity.nil?
      # don't have one by id so see if we have a match by credentials, take the most recent
      identity = FacebookIdentity.where(:credentials => credentials).order("updated_at desc").first
    end

    # if we have an identity, dig up the associated user
    # so we we can log in to that account without password
    if identity
      user = identity.user
      user = nil if user.automatic? # can't log in an automatic user with credentials
    end

    return user, identity, service_user_id
  end

  # update the info for this users identity for facebook login
  def update_facebook_identity(user, credentials, service_user_id)
    identity = user.identity_for_facebook
    return if identity.credentials == credentials && identity.service_user_id == service_user_id
    identity.credentials = credentials
    identity.service_user_id = service_user_id
    while true
      begin
        identity.save!
        break
      rescue ActiveRecord::RecordNotUnique => ex
        # somebody else has this so reset the other record and try again
        other_identity = FacebookIdentity.find_by_service_user_id(service_user_id)
        other_identity.service_user_id = nil
        other_identity.save!
      end
    end
  end

end