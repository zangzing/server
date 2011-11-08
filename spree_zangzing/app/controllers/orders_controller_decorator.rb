OrdersController.class_eval do
  ssl_required :index, :edit, :show, :populate, :thankyou, :update, :checkout  # all except :add_top_order

  before_filter :require_user, :only => [:index]
  before_filter :check_authorization

  helper 'checkout','photo', 'tracking'

  respond_to :json, :only => [:add_photo, :add_to_order]

  def add_to_order
    order = current_order(true)
    variant = Variant.active.find_by_product_id_and_sku(params[:product_id], params[:sku])

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

    # If the referer is  from the photo service save it.
    # If the referer is  from within the store do not save it.
    uri = URI::parse( request.referer )
    unless uri.path =~ /^\/store\//
      session[:store_entrance_referer] = request.referer
    end

    #validate all photos in the cart
    if !@order.all_photos_valid?
       flash.now[:error]="Please Review Your Order"
      flash.now[:payment]='A photo was deleted while in your cart. )'+\
                                      ' The item has been removed and your cart re-calculated.)'
    end

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
        session[:return_to]=user_pretty_url( user )
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

  # desctivate buy mode and go back to last screen before store
  def back_to_viewing_photos
    clear_buy_mode_cookie
    redirect_to session[:store_entrance_referer] ? session[:store_entrance_referer] : root_path
  end

  def back_to_shopping
    redirect_to session[:store_entrance_referer] ? session[:store_entrance_referer] : root_path
  end


  def checkout
    @order = current_order
    if @order.update_attributes(params[:order])
      @order.line_items = @order.line_items.select {|li| li.quantity > 0 }
      respond_with(@order) { |format| format.html { redirect_to checkout_path } }
    else
      respond_with(@order)
    end
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

  #Added this method to avoid the DEPRECATION warning with human_name
  def accurate_title
    @order && @order.completed? ? "#{Order.model_name.human} #{@order.number}" : I18n.t(:shopping_cart)
  end

end

