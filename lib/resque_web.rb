require 'sinatra/base'

class ResqueWeb < Sinatra::Base
  require 'resque/server'
  use Rack::ShowExceptions
  
  # HTTP Auth For Resque Console
  if HTTP_AUTH_CREDENTIALS
    Resque::Server.use Rack::Auth::Basic do |username, password|
     username == HTTP_AUTH_CREDENTIALS[:login] && password == HTTP_AUTH_CREDENTIALS[:password]
    end
  end

  def call(env)
    if env["PATH_INFO"] =~ /^\/resque/
      env["PATH_INFO"].sub!(/^\/resque/, '')
      env['SCRIPT_NAME'] = '/resque'
      app = Resque::Server.new
      app.call(env)
    else
      super
    end
  end

end

