class FacebookPostsController < FacebookController
  def index
    fb_user = 'me'
    feed = facebook_graph.get("#{fb_user}/feed")
    respond_to do |wants|
      wants.html { @feed = feed}
      wants.json { render :json => feed.to_json }
    end
  end

  def create
    response = facebook_graph.post("me/feed", :message => params[:message])
    render :text => response.inspect
  end
end