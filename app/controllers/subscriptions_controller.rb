class SubscriptionsController < ApplicationController
  def unsubscribe
   @subs = Subscriptions.find_by_unsubscribe_token!( params[:id] )
  end

  def update
     @subs = Subscriptions.find( params[:id])
     @subs.update_attributes( params[:subscriptions] )
     flash[:notice] = 'Your email preferences have been saved!'
     redirect_to :back
  end
end