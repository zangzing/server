#
# PasswordResetsController
#
# Controls the flow of the password reset process
#
# 1.- A user clicks on the password reset link
# 2.- The new view is used to generate the form that asks for the user email
# 3.- If the email is not found, try again. If found send the email
#     Before sending the email, a one time perishable token is created and used to
#      to build the link in the email
# 4.- When the user clicks on the link, it is routed to edit and the user is fetched
#     using the perishable token as a key.
# 5.- Password is updated and user logged in.


class PasswordResetsController < ApplicationController
  # These operations require that no user is logged in
  before_filter :require_no_user

  # Use the load.... method for edit and update
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  layout false

  def new
  end

  def create
      @user = User.find_by_email(params[:email])
      if ! @user
        @user = User.find_by_username(params[:email])
      end
      
      if @user
         @user.deliver_password_reset_instructions!
         @reset_success = true
      else
         flash.now[:error] = "Sorry, we could not find that username or email address in our records"
      end
      render :action => :new
  end


  def edit
    #render view
  end

  def update
    @user.reset_password = true
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    #Saving the user while changing the password automatically updates the session and user gets logged in.
    if @user.save
      @user.reset_perishable_token!
      flash[:notice] = "Password successfully updated"
      session[:flash_dialog] = true
      redirect_to user_pretty_url( @user )
    else
      render :action => :edit
    end
  end

private

  #
  #Retrieve the user from the DB using the perishable token if still valid
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      @bad_perishable_token = true
      render :action => :new and return
    end
  end
end
