# this file is loaded once to kick things off
# do any global set up here
# we also load all the initializers before anything else
require 'rubygems'
require 'bundler/setup'
require 'require_all'
require 'logger'
require 'load_paths'
# set up load path order, will check them in the order shown
prepend_load_path(['config/initializers', 'lib', 'app/controllers','../lib'])

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




