#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class ActivationsController < ApplicationController
  before_filter :require_no_user
  def create

        @user = User.find_using_perishable_token(params[:activation_code], 1.week)
        if @user.nil?
           @user_session = UserSession.new
           @user_session.errors.add( :base, "your activation email has expired!" )
           @user = User.find_using_perishable_token(params[:activation_code])
           if @user
              @user_session.errors.add( :base, '<a href="'+
                        resend_activation_path(:username => @user.username)+
                       '">Resend activation email</a>');
           else
             @user_session.errors.add( :base, 'Please Login');
           end
          render 'user_sessions/new' and return
        end
        
        if @user.active?
          flash[:notice] = "Your account has already been activated please login!"
          redirect_to signin_url and return
        end

        if @user.activate!
          flash[:notice] = "Your account has been activated!"
          UserSession.create(@user, true) # Log user in manually
          @user.deliver_welcome!
          redirect_to root_url
        else
          redirect_to signin_url
        end                                                       
  end

  def resend_activation
    if params[:username]
      @user = User.find_by_username( params[:username] )
      if @user && !@user.active?
        @user.deliver_activation_instructions!
        flash[:notice] = "Please check your e-mail for your account activation instructions!"
        redirect_to signin_url
      end
    end
  end
end