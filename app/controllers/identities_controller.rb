class IdentitiesController < ApplicationController

  before_filter :require_user

  layout false

  def index
   render
  end

  def destroy
    if params[:id].is_a? (Integer)
      identity = current_user.identities.find_by_id( params[:id] )
    else
      identity = current_user.send( "identity_for_#{params[:id]}" );
    end

    if identity.destroy
      flash[:notice] = "Authorization to access your #{identity.name } has been removed"
      render :action => 'index', :result => 200
    else
      flash[:error] = "Unable to delete authorization to access your #{identity.name}"
      render :action => 'index', :result => 500
    end
  end

end
