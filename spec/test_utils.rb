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