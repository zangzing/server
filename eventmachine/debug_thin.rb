require 'app_init'

# we use this to simplify debug starts, just run this and we
# will start the server, for the full deploy config we use config.ru

# The additions to env for async.connection and async.callback absolutely
# destroy the speed of the request if Lint is doing it's checks on env.
# It is also important to note that an async response will not pass through
# any further middleware, as the async response notification has been passed
# right up to the webserver, and the callback goes directly there too.
# Middleware could possibly catch :async, and also provide a different
# async.connection and async.callback.

# use Rack::Lint
starter = ThinStarter.new(0)
address = starter.get_address
port = starter.get_port
if port.nil?
  starter.stop_other_start_us(address)
else
  starter.stop_other_start_us(address, port)
end
