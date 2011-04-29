class Connector::TwitterPostsController < Connector::TwitterController
  def index
    feed = twitter_api.client.friends_timeline
    respond_to do |wants|
      wants.html { @feed = feed}
      wants.json { render :json => feed.to_json }
    end
  end

  def create
    response = nil
    SystemTimer.timeout_after(http_timeout) do
      response = call_with_error_adapter do
        twitter_api.client.update(params[:message])
      end
    end
    render :json => response
  end
end