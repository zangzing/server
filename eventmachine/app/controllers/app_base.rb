require 'thin'
require 'json'

# base class for apps
class AppBase
  attr_reader :params, :json_data
  # This is a template async response.
  ErrorResponse = [500, {}, []].freeze

  def initialize(base_path, internal_proxy)
    @request_count = 0
    @base_path = base_path + '/'
    @internal_proxy = internal_proxy
  end

  def request_count
    @request_count
  end

  def request_bump
    @request_count += 1
  end

  def logger
    AsyncConfig.logger
  end

  # strips off the base and returns
  # remaining request string
  def strip_base(env)
    stripped = nil
    req_path = env['REQUEST_PATH']
    stripped = req_path[@base_path.length..-1]
  end

  # this is a super simple dispatcher
  # that expects to match a method with
  # the same name as the path with the
  # base stripped off
  def dispatch_request(env)
    @params = Hash.recursively_symbolize_graph!(Rack::Utils::parse_query(env['QUERY_STRING']))
    @json_data = @internal_proxy ? (EventMachineRPC.parse_json_from_file(@params[:json_path]) rescue {}) : {}
    method = strip_base(env)
    self.send(method.to_sym, env)
  end

  # we are being called to handle our url sync
  def call(env)
    begin
      request_bump

      # expected to return the response in an array of
      # [http_status, {headers}, [enumerable body]]
      response = dispatch_request(env)
    rescue Exception => ex
      # log exception
      msg = "EventMachine incoming request failed for #{env['REQUEST_PATH']} with: #{EMUtils.small_back_trace(ex, 15)}"
      logger.error(msg)
      response = ErrorResponse
    end
    response
  end
end
