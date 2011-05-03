class SubscriptionsController < ApplicationController
  def unsubscribe
   @subs = Subscriptions.find_by_unsubscribe_token!( params[:id] )
   render :layout =>false
  end

  def update
     @subs = Subscriptions.find( params[:id])
     @subs.update_attributes( params[:subscriptions] )
     flash[:notice] = 'Your email preferences have been saved!'
     case params[:next]
      when 'join'
        redirect_to :controller =>:users, :action => :join, :email=>@subs.email, :email2=>@subs.email
      when 'signin'
        redirect_to :controller =>:user_sessions, :action => :new, :email=>@subs.email, :email2=>@subs.email
       else
        redirect_to :back
     end
  end
end