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

# path element that lets you use the tmp directory
Paperclip.interpolates :tmpdir do |att, style|
  Dir.tmpdir
end

# Load the paperclip.yml configuration file
if defined?(Rails.root) and File.exists?("#{Rails.root}/config/paperclip.yml")
    Paperclip.options.merge!(YAML::load(ERB.new(File.read("#{Rails.root}/config/paperclip.yml")).result)[Rails.env].recursively_symbolize_keys!)
    command_path = Paperclip.options[:command_path]
    default_msg = ""
    if command_path.nil?
      default_msg = " WARNING: PATH WAS NOT SET, USING DEFAULT, MAKE SURE THIS MATCHES YOUR ENVIRONMENT"
      command_path = "/usr/bin"
      Paperclip.options[:command_path] = command_path
    end
    msg = "=> Paperclip options file loaded. command_path for ImageMagick is: " + command_path + default_msg
    Rails.logger.info msg
    puts msg
else
     abort %{ZangZing config/paperclip.yml file not found. UNABLE TO INITIALIZE PHOTO STORAGE!}
end

def get_bucket_picker
  Proc.new {|a|
    buckets = a.options[:s3buckets]
    # pick a random bucket - this is important because
    # the old technique always ended up with the same one
    # due to the forking behavior of resque tasks
    buckets[rand(buckets.count)]
    }
end

# Create a proc to compute the right bucket and store it in the options
Paperclip.options[:image_options][:bucket] = get_bucket_picker
Paperclip.options[:picon_options][:bucket] = get_bucket_picker

