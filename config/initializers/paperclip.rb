#
#   � 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

# For more S3 options
# look http://rdoc.info/projects/thoughtbot/paperclip under Paperclip::Storage::S3
#

# Monkey load a Kernel addition to be able to silence warnings when writing code within a silence_warnings block
module Kernel
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end





# Monkey patch paperclip attachment, add original_path and override path()
Paperclip.interpolates :directory do |att, style|
  if att.instance_read(:path).nil?
    "#{attachment( att, style)}/#{id( att, style)}"
  else
     "#{att.instance_read(:path)}"
  end
end

# Load the paperclip.yml configuration file
if defined?(Rails.root) and File.exists?("#{Rails.root}/config/paperclip.yml")
    Paperclip.options.merge!(YAML::load(ERB.new(File.read("#{Rails.root}/config/paperclip.yml")).result)[Rails.env].recursively_symbolize_keys!)
    msg = "=> Paperclip options file loaded. command_path for ImageMagick is: "+ ( Paperclip.options[:command_path]?Paperclip.options[:command_path] : "NOT SET")
    Rails.logger.info msg
    puts msg
else
     abort %{ZangZing config/paperclip.yml file not found. UNABLE TO INITIALIZE PHOTO STORAGE!}
end

# Create a proc to compute the right bucket and store it in the options
Paperclip.options[:image_options][:bucket] =
    Proc.new {|a| (a.options[:s3buckets].push a.options[:s3buckets].shift)[0]}
Paperclip.options[:picon_options][:bucket] =
    Proc.new {|a| (a.options[:s3buckets].push a.options[:s3buckets].shift)[0]}

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
