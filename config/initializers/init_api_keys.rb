#Loading timeouts
SERVICE_CALL_TIMEOUT = YAML.load(ERB.new(File.read("#{Rails.root}/config/service_timeouts.yml")).result)


api_creds = {}
[:flickr, :facebook, :smugmug, :shutterfly, :twitter, :yahoo, :photobucket, :ms_live,
:bitly, :mailchimp, :zza, :instagram].each do |service|
  all_env_keys = YAML.load(File.read("#{Rails.root}/config/#{service}_api_keys.yml"))
  api_creds[service] = all_env_keys[Rails.env]
end

FLICKR_API_KEYS       = api_creds[:flickr]
FACEBOOK_API_KEYS     = api_creds[:facebook]
SMUGMUG_API_KEYS      = api_creds[:smugmug]
SHUTTERFLY_API_KEYS   = api_creds[:shutterfly]
PHOTOBUCKET_API_KEYS  = api_creds[:photobucket]
INSTAGRAM_API_KEYS    = api_creds[:instagram]
YAHOO_API_KEYS        = api_creds[:yahoo]
TWITTER_API_KEYS      = api_creds[:twitter]
WINDOWS_LIVE_API_KEYS = api_creds[:ms_live]
BITLY_API_KEYS        = api_creds[:bitly]  #YAML.load(File.read("#{Rails.root}/config/bitly_api_keys.yml"))
MAILCHIMP_API_KEYS    = api_creds[:mailchimp]
ZZA_CONFIG            = api_creds[:zza]

msg = "=> Connector API keys loaded."
Rails.logger.info msg
puts msg
