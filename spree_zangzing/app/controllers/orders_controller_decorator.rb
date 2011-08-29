OrdersController.class_eval do
  before_filter :check_authorization


  respond_to :json, :only => [:add_photo]

  def add_photo
    @order = current_order(true)
    variant = Variant.find_by_sku(Spree::Config[:default_print_sku])
    photo = Photo.find( params[:photo_id] )
    li_photo_data = LineItemPhotoData.new(
        :photo_id   => params[:photo_id],
        :source_url => photo.thumb_url
    )
    @order.add_variant( variant,  li_photo_data, 1 )
    respond_with( @order )
  end

  # the inbound variant is determined either from products[pid]=vid or variants[master_vid], depending on whether or not the product has_variants, or not
  #
  # Currently, we are assuming the inbound ad_hoc_option_values and customizations apply to the entire inbound product/variant 'group', as more surgery
  # needs to occur in the cart partial for this to be done 'right'
  #
  def populate
    @order = current_order(true)

    params[:products].each do |product_id,variant_id|
      quantity = params[:quantity].to_i if !params[:quantity].is_a?(Hash)
      quantity = params[:quantity][variant_id].to_i if params[:quantity].is_a?(Hash)
      @order.add_variant(Variant.find(variant_id), photo_data, quantity) if quantity > 0
    end if params[:products]

    params[:variants].each do |variant_id, quantity|
      quantity = quantity.to_i
      @order.add_variant(Variant.find(variant_id),  photo_data, quantity) if quantity > 0
    end if params[:variants]

    redirect_to cart_path
  end


  private
  # given params[:customizations], return a non-persisted  PhotoProductCustomData object
  def photo_data
    # do we have any photo_data?
    ppcd = nil
    if params[:photo_data]
      ppcd = LineItemPhotoData.new( params[:photo_data] )
    end
    ppcd
  end


  # This method allows guests who placed an order to view it online
  # (via a cookie placed in their session)
  # users to view the orders they own.
  def check_authorization
    session[:access_token] ||= params[:token]
    order = current_order || Order.find_by_number(params[:id])

    if order
      unless current_user.id == order.user.id || order.token == session[:access_token]
         render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      end
    else
      true
    end
  end

end

