ProductsController.class_eval do

  respond_to :json, :only =>[ :index, :show ]

end