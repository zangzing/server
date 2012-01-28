class UsersController < ApplicationController
  ssl_required :join, :create, :edit_password, :update_password
  ssl_allowed :validate_email, :validate_username

  skip_before_filter :verify_authenticity_token, :only=>[:create]

  def join

    # URL Cleaning cycle
    if params[:return_to] || params[:email]
      session[:return_to] = params[:return_to] if params[:return_to]
      flash.keep
      unless current_user
        session[:email] = params[:email] if params[:email]
        redirect_to join_url and return
      end
    end

    if current_user
      redirect_back_or_default user_pretty_url(current_user)
      return
    end

    if session[:email]
      @new_user = User.new(:email => session[:email] )
      session.delete(:email)
    else
      @new_user = User.new
    end
    render :layout => false
  end

  def create

    if current_user
        flash[:notice] = "You are currently logged in as #{current_user.username}. Please log out before creating a new account."
         add_javascript_action( 'show_message_dialog',  {:message => flash[:notice]})
         redirect_back_or_default user_pretty_url(current_user)
        return
    end

    clear_buy_mode_cookie

    @user_session = UserSession.new

    # RESERVED NAMES
    # check username if in magic format
    user_info = params[:user]
    checked_user_name = check_reserved_username(user_info)
    if checked_user_name.nil?
      @new_user = User.new()
      @new_user.set_single_error(:username, "You attempted to use a reserved user name without the proper key." )
      render :action => :join, :layout => false and return
    end

    # AUTOMATIC USERS
    #Check if user is an automatic user ( a contributor that has never logged in but has sent photos )
    @new_user = User.find_by_email( params[:user][:email])
    if @new_user && @new_user.automatic?
      # The user is an automatic user because she had contributed photos after being invited by email
      # she has now decided to join, remove automatic flag and reset password.
      if @new_user.auto_by_contact
        @new_user.cohort = User.cohort_current # if they are auto due to simply being created because someone referenced that email address then the real cohort is now
        @new_user.auto_by_contact = false       # a full user now
      end
      @new_user.automatic = false
      @new_user.name      = params[:user][:name]
      @new_user.username  = params[:user][:username]
      @new_user.reset_password = true
      @new_user.password = params[:user][:password]
      @new_user.password_confirmation  = @new_user.password
    else
      @new_user = User.new(params[:user])
    end
    @new_user.reset_perishable_token
    @new_user.reset_single_access_token

    # SIGNUP CONTROL
    # new users are active by default
    if SystemSetting[:signup_control]
      @new_user.active = false
      @guest = Guest.find_by_email( params[:user][:email] )
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
        
        if params[:follow_user_id] and User.exists? params[:follow_user_id]
          Like.add(@new_user.id, params[:follow_user_id], Like::USER)
        end

        flash[:success] = "Welcome to ZangZing!"
        @new_user.deliver_welcome!
        add_javascript_action('show_welcome_dialog') unless( session[:return_to] )
        send_zza_event_from_client('user.join')
        redirect_back_or_default user_pretty_url( @new_user )

        # process tracking token if there was one
        if current_tracking_token
          TrackedLink.handle_join(@new_user, current_tracking_token)
        end

        # process any invitations tied to this email address or tracking token
        invitation = Invitation.process_invitations_for_new_user(@new_user, current_tracking_token)

        # send zza events
        if invitation
          send_zza_event_from_client('invitation.join')

          if invitation.tracked_link # there should always be one, but just in case of bug
            send_zza_event_from_client("invitation.#{invitation.tracked_link.shared_to}.join")
          end

        end

        return
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
        redirect_to inactive_url and return
      end
    end
    
    
    
    render :action=>:join,  :layout => false
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
      @user = User.find_by_email(params[:user][:email])
      if @user == current_user #if the email returns the current user this means its a profile edit
        @user = nil
      end
      if @user && @user.automatic?
        render :json => true and return  #The user is an automatic user so the email is still technically available.
      end
      render :json => !@user and return
    end
    render :json => true #Invalid call return not valid
  end

  def validate_username
    if params[:user] && params[:user][:username]
      if ReservedUserNames.is_reserved? params[:user][:username]
        render :json => false and return
      elsif
        @user = User.find_by_username(params[:user][:username])
        if @user == current_user #if the username returns the current user this means its a profile edit
          @user = nil
        end
        if @user && @user.automatic?
          render :json => true and return  #The user is an automatic user so the username is still technically available.
        end
        render :json => !@user and return
      end

    end
    render :json => true #Invalid call return not valid
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
  #        :first_name => first_name,
  #        :last_name => last_name,
  #        :email => email for this user (this will only be present for automatic users and in cases where you looked up the user via email)
  #        :automatic => true if an automatic user (one that has not created an account)
  #        :auto_by_contact => true if automatic user and was created simply by referencing (i.e. we added automatic as result of group or permission operation)
  #                            if automatic is set and this is false it means we have a user that has actually sent a photo in on that address
  # }
  def zz_api_user_info
    return unless require_nothing
    zz_api do
      user_id = params[:user_id]
      user = User.find(user_id)
      user_info = user.basic_user_info_hash
    end
  end

  # Finds or creates users.
  #
  # This will find existing users and in the email case create automatic users
  # for emails that do not map to a current user. Finding by user_ids and user_names
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
  # This call does not require you to be logged in.
  #
  # Input:
  # {
  #   :user_ids => [ array of user ids to find ],
  #   :user_names => [ array of user names to find ],
  #   :emails => [ array of emails to find or create ],
  # }
  #
  #
  # Returns:
  # fetches and returns all users found or created in the form
  #
  # [
  #   user_info_hash - the hash containing the user info as returned in the user info call
  #   ...
  # ]
  #
  def zz_api_find_or_create
    return unless require_nothing
    zz_api do
      user_ids = []
      user_ids += User.validate_user_ids(params[:user_ids])
      user_ids += User.validate_user_names(params[:user_names])
      addresses = User.validate_emails(params[:emails])
      converted_ids, user_id_to_email = User.convert_to_users(addresses)
      user_ids += converted_ids

      members = preload_users(user_ids)
      User.as_array(members, user_id_to_email)
    end
  end

  private

  # efficient fetch of users prepped to be loaded
  def preload_users(user_ids)
    members = User.where(:id => user_ids).includes(:profile_album).all
    albums = []
    members.each do |member|
      albums << member.profile_album
    end
    Album.fetch_bulk_covers(albums)
    # ok, we are pre-flighted with everything we need loaded now
    members
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



end