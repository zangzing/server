# This is custom restart code for handling cases other than the
# basic app server restart
#
# This code runs just before the app server restarts.
#
# Generally used to restart things like resque workers and such
#
# If we are running with a no downtime deploy whatever we restart
# here needs to be able to handle a brief period of traffic from the
# old data in the queues since their may be old requests pending and
# also the old app server version is still running and can generate
# new events until it switches over.
#

#run "sudo monit stop all -g resque_photos"
#run "sudo monit restart all -g resque_photos"



# make sure v3homepage is deployed with the current tag, technically we really only
# need this to run when we have newly added machines but there is really no way to know
# so we run it each time.  The downside is that this is a fairly lengthy operation
# We only need to run on one instance, so use the app_master or solo - they are mutually
# exclusive
if [:solo, :app_master].include?(zz_role)
  run "bundle exec rails runner -e #{zz_rails_env} HomepageManager.deploy_homepage_current_tag_async"
end

