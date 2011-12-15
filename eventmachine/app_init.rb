# this file is loaded once to kick things off
# do any global set up here
# we also load all the initializers before anything else
require 'rubygems'
require 'bundler/setup'
require 'require_all'
require 'logger'

# add the array of sub dirs to the load path
def prepend_load_path(sub_dirs)
  priority = sub_dirs.reverse
  priority.each do |sub_dir|
    path = File.expand_path(File.join(File.dirname(__FILE__), sub_dir))
    #puts path
    $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  end
end
# set up load path order, will check them in the order shown
prepend_load_path(['config/initializers', 'lib', 'app/controllers','../lib','../app/metal'])

# now load all the initializers and lib files
require_rel 'config/initializers'
require_rel 'lib'
require_rel 'app/controllers'

# load the config
cfg = AsyncConfig.config

# load the logger
AsyncConfig.logger = load_logger

require 'zz/zza'
# assign our zza_id
ZZ::ZZA.default_zza_id = cfg[:zza_id]




