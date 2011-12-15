class RouteManager
  BASE_PROXY = '/proxy_eventmachine'
  BASE_DIRECT = '/eventmachine'

  # set up the app routes here and return the server
  def self.create_routes(*args)
    # make an instance of each app type (controller)
    zip_app = ZipAsyncApp.new(BASE_PROXY, true)
    heap_app = HeapStatsApp.new(BASE_PROXY, true)

    # map your routes
    server = Thin::Server.new(*args) do
      use Rack::CommonLogger
      use HeapTracker

      map "#{BASE_PROXY}/zip_download" do
        run  zip_app
      end

      map "#{BASE_PROXY}/heap" do
        run  heap_app
      end

      map "#{BASE_PROXY}/heap_track" do
        run  heap_app
      end
    end

    AsyncConfig.server = server
    return server
  end

end
