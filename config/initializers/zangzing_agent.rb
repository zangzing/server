#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

ZANGZING_AGENT_CONFIG = []

# Load the agent_config.yml configuration file
if defined?(Rails.root) and File.exists?("#{Rails.root}/config/agent_config.yml")
    ZANGZING_AGENT_CONFIG = YAML::load(File.read("#{Rails.root}/config/agent_config.yml"))
    msg = "=> Agent configuration file loaded."
    Rails.logger.info msg
    puts msg
else
     abort %{ZangZing config/agent_config.yml file not found. UNABLE TO CONFIGURE AGENT OPTIONS!}
end

#ZANGZING_AGENT_CONFIG['agents'].each do | key, value |
#  puts key
#  value.each do |vkey,vvalue|
#    puts "\t"+vkey
#    vvalue.each do |vvkey,vvvalue|
#       puts "\t\t"+vvkey
#       puts "\t\t\tcheck:"+vvvalue['check']
#      puts "\t\t\turl:"+vvvalue['url'].to_s
#    end
#  end
#end
