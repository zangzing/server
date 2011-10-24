ProductsController.class_eval do

  respond_to :json, :only =>[ :index, :show ]

  def index
    @searcher = Spree::Config.searcher_class.new(params)
    @products = @searcher.retrieve_products

    #expires_in 10.minutes, :public => true

    respond_with(@products)
  end

end