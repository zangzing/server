ProductsController.class_eval do

  respond_to :json, :only =>[ :index ]

  def index
    # grab the data in compressed json form
    products_json = Product.fetch_all_compressed_json # fetch from cache or create if first time

    params[:ver] = 1  # fake the version for now to provide an expires to the client
    render_cached_json(products_json, true, true, 10.minutes)
  end

  def show

    @product = Product.find(params[:id])
    return unless @product

    @variants = Variant.active.includes([:option_values, :images]).where(:product_id => @product.id)
    @product_properties = ProductProperty.includes(:property).where(:product_id => @product.id)
    @selected_variant = @variants.detect { |v| v.available? }

    render :layout => false

  end

end