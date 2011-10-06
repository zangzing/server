OrdersController.class_eval do

  before_filter :require_user, :only => [:index]
  before_filter :check_authorization

  helper 'checkout','photo'

  respond_to :json, :only => [:add_photo, :add_to_order]

  def add_to_order
    order = current_order(true)
    variant = Variant.find_by_product_id_and_sku(params[:product_id], params[:sku])

    params[:photo_ids].each do |photo_id|
      photo = Photo.find( photo_id )
      order.add_variant( variant,  photo, 1 )
    end

    respond_with( order )

  end

  def index
     @orders = Order.complete.find_all_by_user_id( current_user.id )
    respond_with( @orders )
  end

   # Shows the current incomplete order from the session
  def edit
    @order = current_order(true)
    @order.state = 'cart'
    render :layout => 'checkout'
  end

  def show
    @order = Order.find_by_number(params[:id])
    render :layout => 'checkout'
  end


  # the inbound variant is determined either from products[pid]=vid or variants[master_vid], depending on whether or not the product has_variants, or not
  #
  # Currently, we are assuming the inbound ad_hoc_option_values and customizations apply to the entire inbound product/variant 'group', as more surgery
  # needs to occur in the cart partial for this to be done 'right'
  #
  def populate
    @order = current_order(true)

    params[:products].each do |product_id,variant_id|
      if params[:quantity].is_a?(Hash)
        quantity = params[:quantity][variant_id].to_i
      else
        quantity = params[:quantity].to_i 
      end
      @order.add_variant(Variant.find(variant_id), photo, quantity) if quantity > 0
    end if params[:products]

    params[:variants].each do |variant_id, quantity|
      quantity = quantity.to_i
      @order.add_variant(Variant.find(variant_id),  photo, quantity) if quantity > 0
    end if params[:variants]

    redirect_to cart_path
  end

  def thankyou
    @order = Order.find_by_number(params[:id])
    if @order.nil?
        redirect_to cart_path and return
    end

    if !current_user
      user = User.find_by_email(@order.email)
      if user  #a user exists wit the email used
        @user_session = UserSession.new( :email => @order.email )
      else    #a never seen email
       session[:return_to]=root_path
       @user = User.new(
           :first_name => @order.bill_address.firstname,
           :last_name  => @order.bill_address.lastname,
           :email      => @order.email
       )
      end
    end
    render :layout => 'checkout'
   end

  private
  # given params[:customizations], return a non-persisted  PhotoProductCustomData object
  def photo
    Photo.find_by_id( params[:photo_id] ) if params[:photo_id]
  end

  # This method allows guests who placed an order to view it online
  # (via a cookie placed in their session)
  # users to view the orders they own.
  def check_authorization
    session[:access_token] ||= params[:token]
    order = current_order || Order.find_by_number(params[:id])

    if order
      return true if current_user && current_user.id == order.user.id
      return true if order.token == session[:access_token]
      render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      return false
    else
      true
    end
  end

end

