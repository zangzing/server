class PreferencesController < ApplicationController
  def unsubscribe
   @up = UserPreferences.find_by_unsubscribe_token!( params[:id] )
  end

  def update
     @up = UserPreferences.find( params[:id])
     @up.update_attributes( params[:user_preferences] )
     flash[:notice] = 'Your email preferences have been saved!'
     redirect_to :back
  end
end