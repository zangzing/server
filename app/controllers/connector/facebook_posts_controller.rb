class Connector::FacebookPostsController < Connector::FacebookController
  def index
    fb_user = 'me'
    feed = facebook_graph.get("#{fb_user}/feed")
    respond_to do |wants|
      wants.html { @feed = feed}
      wants.json { render :json => feed.to_json }
    end
  end

  def create
    response = nil
    SystemTimer.timeout_after(http_timeout) do
      response = facebook_graph.post("me/feed", :message => params[:message],
          :link => album_url(params[:album_id]) #,
          #:picture => 'http://duhast.homeip.net/images/logo-zangzing.png',
          #:name => 'NAme here',
          #:caption => "Smith hails 'unique' Wable legacy",
          #:description => 'John Smith claims beautiful football is the main legacy of Akhil Wable''s decade at the club.',
          #:source => 'http://www.elance.com'
        )
    end
    render :text => response.inspect
  end
end