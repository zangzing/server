class FacebookPostsController < FacebookController
  def index
    fb_user = params[:facebook_user_id] || 'me'
    @feed = facebook_graph.get("#{fb_user}/feed")
  end

  def create
    response = facebook_graph.post("#{params[:facebook_user_id]}/feed", :message => params[:message])
    render :text => response.inspect
  end
end