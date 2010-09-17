#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
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

# Monkey patch replacement for a regular expression used by delayed_job on IDs. The original did not work
# with dashes in the id and since guid uses dashed then we monkey patch this version.
# the original can be found inside  the delayed_job gem  lib/performable_method.rb line 12
silence_warnings do
  module Delayed
    class PerformableMethod
      STRING_FORMAT = /^LOAD\;([A-Z|-][\w\:]+)(?:\;([\w-]+))?$/
    end
  end
end

# Monkey load a method to recursively symbolize keys into the Hash class
class Hash
  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        #v.recursively_symbolize_keys!
      end
    end
    self
  end
end


# Load the paperclip.yml configuration file
if defined?(RAILS_ROOT) and File.exists?("#{RAILS_ROOT}/config/paperclip.yml")
    Paperclip.options.merge!(YAML::load(ERB.new(File.read("#{RAILS_ROOT}/config/paperclip.yml")).result)[RAILS_ENV].recursively_symbolize_keys!)
    puts "=> Paperclip options file loaded. command_path for ImageMagick is: "+ ( Paperclip.options[:command_path]?Paperclip.options[:command_path] : "NOT SET")
else
     abort %{ZangZing config/paperclip.yml file not found. UNABLE TO INITIALIZE PHOTO STORAGE!}
end

# Create a proc to compute the right bucket and store it in the options
Paperclip.options[:image_options][:bucket] =
    Proc.new {|a| (a.options[:s3buckets].push a.options[:s3buckets].shift)[0]}

Picon.test()




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
