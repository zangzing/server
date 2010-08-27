class IdentitiesController < ApplicationController
  def index
    @identities = current_user.identities
  end

  def destroy
    identity = current_user.identities.find(:first, :conditions => {:id => params[:id]})
    if identity.destroy
      flash[:notice] = "Identity ##{identity.id} was deleted"
    else
      flash[:notice] = "Identity ##{identity.id} was not deleted"
    end
    redirect_to :action => 'index'
  end

end
