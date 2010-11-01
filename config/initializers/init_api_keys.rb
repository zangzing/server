api_creds = {}
[:flickr, :facebook, :smugmug, :shutterfly, :twitter, :yahoo, :photobucket].each do |service|
  all_env_keys = YAML.load(File.read("#{RAILS_ROOT}/config/#{service}_api_keys.yml"))
  api_creds[service] = all_env_keys[RAILS_ENV]
end

FLICKR_API_KEYS = api_creds[:flickr]
FACEBOOK_API_KEYS = api_creds[:facebook]
SMUGMUG_API_KEYS = api_creds[:smugmug]
SHUTTERFLY_API_KEYS = api_creds[:shutterfly]
PHOTOBUCKET_API_KEYS = api_creds[:photobucket]
YAHOO_API_KEYS = api_creds[:yahoo]
TWITTER_API_KEYS = api_creds[:twitter]