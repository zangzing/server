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

#run "sudo monit restart all -g resque_photos"



# make sure v3homepage is deployed with the current tag, technically we really only
# need this to run when we have newly added machines but there is really no way to know
# so we run it each time.  The downside is that this is a fairly lengthy operation
# We only need to run on one instance, so use the app_master or solo - they are mutually
# exclusive
if [:solo, :app_master].include?(zz_role)
  run "bundle exec rails runner -e #{zz_rails_env} HomepageManager.deploy_homepage_current_tag_async"
end

