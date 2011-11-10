Admin::OverviewController.class_eval do
    ssl_required

  # clear all the spree caches - we cache stuff
  # for efficiency but to change products or shipping
  # methods you need to call this method to clear out
  # those caches
  def clear_all_caches
    Order.clear_caches
    Product.clear_caches
    render :text => "All spree caches have been cleared."
  end
end