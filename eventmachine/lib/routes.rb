class RouteManager

  # set up the app routes here and return the server
  def self.create_routes(*args)
    # make an instance of each app type (controller)
    zip_app = ZipAsyncApp.new

    # map your routes
    server = Thin::Server.new(*args) do
      use Rack::CommonLogger
      map '/zip_download' do
        run  zip_app
      end
    end

    AsyncConfig.server = server
    return server
  end

end
