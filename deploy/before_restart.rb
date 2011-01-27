# This is an EngineYard deploy hook. 
# It is executed after the whole deploy process is finished and the application is ready to be restarted

#Use Jammit gem to package css and jacasctipt
run "bundle exec jammit"


# Symlink nginx conf files

# Symlink Resque Files

# remove and symlink resque.yml with proper location of redis server - the shared path
# file was set up by custom chef script
run "ln -nfs #{shared_path}/config/resque.yml #{release_path}/config/resque.yml"

# Restart Resque workers
run "sudo monit restart all -g zangzing_resque"

#ALL DONE! Restart the App.
