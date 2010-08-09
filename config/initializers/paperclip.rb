#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
if Rails.env.production?
    Paperclip.options[:log] = false
    Paperclip.options[:log_command] = false
else
    Paperclip.options[:command_path] = ENV['IMAGEMAGICK_PATH'] #look for imagemagick here
end
  
# if defined?(RAILS_ROOT) and File.exists?("#{RAILS_ROOT}/config/paperclip.yml")
#    Paperclip.options.merge(YAML.load_file("#{RAILS_ROOT}/config/paperclip.yml")[RAILS_ENV].symbolize_keys)
# end
#
#The YAML File looks like this
#development: &non_production_settings
#  url: "/system/:class/:attachment/:id/:basename-:style.:extension"
#  path: ":rails_root/public:url"
#
#test:
#  url: "/system/:class/:attachment/:id/:basename-:style.:extension"
#  path: ":rails_root/public:url"
#
#production:
#  url: "/system/:class/:attachment/:id/:basename-:style.:extension"
#  path: ":rails_root/public:url"
#  storage: ":s3"
#  bucket: "my-bucket"
