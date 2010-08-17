class TwitterPostsController < TwitterController
  def index
    feed = twitter_api.client.friends_timeline
    respond_to do |wants|
      wants.html { @feed = feed}
      wants.json { render :json => feed.to_json }
    end
  end

  def create
    response = twitter_api.client.update(params[:message])
    render :text => response.inspect
  end
end