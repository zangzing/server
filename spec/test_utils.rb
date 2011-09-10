
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
def mobile_headers
  return {'HTTP_X_ZANGZING_API' => 'mobile', 'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}
end

# given a hash convert to a JSON string
def mobile_body(data)
  JSON.fast_generate(data)
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
def resque_loopback(options = nil, &block)
  begin
    filter = FilterHelper.new(options)
    prev_filter = ZZ::Async::Base.loopback_filter
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
  db = parts[2].nil? ? 0 : parts[2]
  redis = Redis.new(:host => host, :port => port, :db => db)
  redis.flushdb
end

