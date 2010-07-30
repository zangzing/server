api_creds = YAML.load(File.read("#{RAILS_ROOT}/config/facebook_api_keys.yml"))
FACEBOOK_API_KEYS = api_creds[RAILS_ENV]