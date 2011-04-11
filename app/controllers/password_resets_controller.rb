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
      if @user
         @user.deliver_password_reset_instructions!
         flash.now[:notice] = "<p>An email to reset your password is on it’s way!</p><br>"+
                          "<p>If it doesn't show up, check your Junk Mail folder.<p/><br>"+
                          "<p>If it's not there then please <a href='mailto:support@zangzing.com'>contact support.</a></p>"
      else
         flash.now[:error] = "Could not find that email address in our records"
      end
      render :action => :new
  end


  def edit

  end

  def update
    @user.reset_password = true;
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password successfully updated"
      UserSession.create(@user, false) # Log user in manually
      @user.reset_perishable_token!
      redirect_to root_url
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
      flash.now[:notice] = "We're sorry, but we could not locate your account.<br> " +
                       "If you are having issues try copying and pasting the URL " +
                       "from your email into your browser or restarting the " +
                       "reset password process <a href='#{new_password_reset_url}'>here</a>."
      render :action => :new and return
    end
  end
end
