ProductsController.class_eval do

  respond_to :json, :only =>[ :index ]

  def index
    @searcher = Spree::Config.searcher_class.new(params)
    @products = @searcher.retrieve_products

    expires_in 10.minutes, :public => true

    respond_with(@products)
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