
#def unique_name(base_name)
#  name = "#{base_name}-#{Time.now.to_i}-#{rand(99999)}"
#end
#

# create the appropriate header types
# if the is_post flag is true we also
# add a Content-Type header - doesn't
# convert headers to the HTTP_ all uppercase form
# so pass in what the rails side expects rather than
# what a real client would send.
def zz_api_headers
  return {'HTTP_X_ZANGZING_API' => 'iphone', 'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}
end

def zz_api_debug=(value)
  @@zz_api_debug = value
end

def zz_api_debug?
  @@zz_api_debug ||= false
end

def zz_api_log(msg)
  puts msg if zz_api_debug?
end

# given a hash convert to a JSON string
def zz_api_body(data)
  zz_api_debug? ? JSON.pretty_generate(data) : JSON.fast_generate(data)
end

def build_full_path_if_needed(path, secure)
  path.index('http') == 0 ? path : build_full_path(path, secure)
end

# wrapper around post that preps for api call
# if expect_ok is set we also return the response
# in json form
def zz_api_post(path, body, expect_code = 200, secure = false)
  body = body.nil? ? nil : zz_api_body(body)
  zz_api_log "zz_api_post body: \n#{body}"
  post build_full_path_if_needed(path, secure), body, zz_api_headers
  zz_api_response(response, expect_code)
end

# wrapper around post that preps for api call
# if expect_ok is set we also return the response
# in json form
def zz_api_put(path, body, expect_code = 200, secure = false)
  body = body.nil? ? nil : zz_api_body(body)
  zz_api_log "zz_api_put body: \n#{body}"
  put build_full_path_if_needed(path, secure), body, zz_api_headers
  zz_api_response(response, expect_code)
end

# wrapper around post that preps for api call
# if expect_ok is set we also return the response
# in json form
def zz_api_delete(path, body, expect_code = 200, secure = false)
  body = body.nil? ? nil : zz_api_body(body)
  delete build_full_path_if_needed(path, secure), body, zz_api_headers
  zz_api_response(response, expect_code)
end

# wrapper around get that preps for api call
# if expect_ok is set we also return the response
# in json form
def zz_api_get(path, expect_code = 200, secure = false)
  get build_full_path_if_needed(path, secure), nil, zz_api_headers
  zz_api_response(response, expect_code)
end


# form the json from the response
# converting keys to symbols
def zz_api_response(response, expect_code)
  j = response.body.length <= 1 ? {} : Hash.recursively_symbolize_graph!(zz_api_response_parse(response.body))

  if expect_code == 200
    response.status.should eql(200)
  else
    j[:code].should eql(expect_code)
  end
  j
end

def zz_api_response_parse(body)
  result = JSON.parse(body)
  zz_api_log "zz_api_response: \n#{JSON.pretty_generate(result)}"
  result
end

def zz_verify_all_fields_match(result, request)
  request.each_pair do |key,value|
    value.should == result[key]
  end
end

# safe wrapper for turning on or off loopback mode
# for resque jobs - this works in a nested fashion
# by fetching the existing filters and then applying
# the new filters and finally restoring the original
# filters on exit to ensure that the state is what
# it was when we were initially called.
#
# it expects a hash in the following form:
#
# {} or nil, means allow all
# {
#   :only => [str1, str2]
# }
# Above allows just str1 and str2
#
# {
#   :except => [str4, str5]
# }
# Above allows all except for str4 and str5
#
def resque_jobs(options = nil, &block)
  begin
    prev_filter = ZZ::Async::Base.loopback_filter
    filter = FilterHelper.new(options)
    ZZ::Async::Base.loopback_filter = filter
    block.call()
  rescue Exception => ex
    raise ex
  ensure
    ZZ::Async::Base.loopback_filter = prev_filter
  end
end


# flush the redis test db
def flush_redis_test_db
  server = RedisConfig.config[:redis_acl_server]
  parts = server.split(':')
  host = parts[0]
  port = parts[1]
  db = parts[2].nil? ? (raise ArgumentError, "You MUST specify the test db part") : parts[2]
  redis = Redis.new(:host => host, :port => port, :db => db)
  redis.flushdb
end

