class IdentitiesController < ApplicationController

  before_filter :require_user

  layout false

  def index
   render
  end

  def destroy
    identity = current_user.identities.find_by_id( params[:id] )
    if identity.destroy
      flash[:notice] = "#{identity.class.to_s.capitalize } Identity  was deleted"
      render :action => 'index', :result => 200
    else
      flash[:error] = "Unable to delete #{identity.type.to_s.capitalize}"
      render :action => 'index', :result => 500
    end
  end

end
