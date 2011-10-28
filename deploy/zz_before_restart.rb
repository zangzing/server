# This hook is called just prior to the application restart code.
# The release directory has been symlinked to current and everything
# is in place and ready for a restart.
#
# If you want complete control over the application restart you
# can instead provide a zz_override_restart.rb file.  We still
# will call this file first but instead of the built in restart
# code we will pass it to zz_override_restart.rb
#
#
# You can determine if we have a downtime deploy by checking
# zz[:deploy_downtime] which will be set to true if we
# have a downtime deploy.
#


# If we are running with a no downtime deploy whatever we restart
# here needs to be able to handle a brief period of traffic from the
# old data in the queues since there may be old requests pending and
# also the old app server version is still running and can generate
# new events until it switches over.  So, the key to remember is
# that any new changes to the resque workers should be backwards
# compatible.
#

# restart the resque workers, do not use monit directly since
# it is very slow (on the order of minutes) to cycle through all
# of them.  Instead we create a script that does the starting and
# stopping more directly.
#
run "sudo /usr/bin/zzscripts/photos_resque_stop_all && sudo /usr/bin/zzscripts/photos_resque_start_all"

# clear out the nginx cache
#run "find /media/ephemeral0/nginx/cache -type f | xargs /bin/rm -f"
# if you want to manually clear the cache of all front end servers with photos_staging from the command line you can use for example:
#zz multi_ssh -g photos_staging -r app,app_master 'find /media/ephemeral0/nginx/cache -type f | xargs /bin/rm -f'



