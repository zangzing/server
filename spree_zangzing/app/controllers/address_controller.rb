class AddressesController < Spree::BaseController

  #rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  #
  #before_filter  load_and_authorize_address
  #
  #def edit
  #  store_location
  #end
  #
  #def update
  #  if @address.editable?
  #    if @address.update_attributes(params[:address])
  #      flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t(:address))
  #    end
  #  else
  #    new_address = @address.clone
  #    new_address.attributes = params[:address]
  #    @address.update_attribute(:deleted_at, Time.now)
  #    if new_address.save
  #      flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t(:address))
  #    end
  #  end
  #  redirect_back_or_default account_path
  #end
  #
  #def destroy
  #  if @address.can_be_deleted?
  #    @address.destroy
  #  else
  #    @address.update_attribute(:deleted_at, Time.now)
  #  end
  #  redirect_to(request.env['HTTP_REFERER'] || account_path) unless request.xhr?
  #end
  #
  #private
  #def load_and_authorize_address
  #  unless current_user
  #    render_401
  #  end
  #  @address = Address.find(params[:id])
  #  unless @address.user_id == current_user.id
  #    render_401
  #  end
  #end

end

