# This is an EngineYard deploy hook. 
# It is executed after the whole deploy process is finished and the application is ready to be restarted

# Symlink nginx conf files

# Symlink Resque Files

# Restart Resque workers
run "monit restart all -g zangzing_resque"

#ALL DONE! Restart the App.
