require 'async'

use Rack::CommonLogger
map '/test' do
  run  AsyncApp.new
end
