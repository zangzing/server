api_creds = YAML.load(File.read("#{RAILS_ROOT}/config/flickr_api_keys.yml"))
FLICKR_API_KEYS = api_creds[RAILS_ENV]

api_creds = YAML.load(File.read("#{RAILS_ROOT}/config/facebook_api_keys.yml"))
FACEBOOK_API_KEYS = api_creds[RAILS_ENV]

api_creds = YAML.load(File.read("#{RAILS_ROOT}/config/smugmug_api_keys.yml"))
SMUGMUG_API_KEYS = api_creds[RAILS_ENV]