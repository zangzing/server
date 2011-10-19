Admin::ProductsController.class_eval do

  def table
    render :layout => false
  end

  def collection_actions
    [:index, :table]
  end

end