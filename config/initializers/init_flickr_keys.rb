api_creds = YAML.load(File.read("#{RAILS_ROOT}/config/flickr_api_keys.yml"))
FLICKR_API_KEYS = api_creds[RAILS_ENV]