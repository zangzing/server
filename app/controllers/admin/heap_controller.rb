# this class provides the UI for the low level heap tracker
# the heap tracker is called as rack middleware so gets inserted
# into each call into the app
class Admin::HeapController < Admin::AdminController

  def index
    html = HeapTracker.current_instance.gc_stats
    expires_now
    render :text => html, :content_type => "text/html"
  end

  def track
    track_on = ZZUtils.as_boolean(params[:on])
    if track_on
      HeapTracker.current_instance.track(true)
      msg = "Memory Tracking on"
    else
      HeapTracker.current_instance.track(false)
      msg = "Memory Tracking off"
    end
    expires_now
    render :text => msg, :content_type => 'text/plain'
  end


end
