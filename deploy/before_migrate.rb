# This is an EngineYard deploy hook. 
# It is executed before the db is migrated. It is the earliest deployment hook
#
# From: http://docs.engineyard.com/appcloud/howtos/configure-and-deploy-resque#redis-configuration

# This is for workers who will be stopped with QUIT
# Tell the resque workers to stop  when they have finished their jobs
#    give them 60 seconds to finish if not kill them.

# If there were any jobs and they have not finished, raise exception and the
# user should try to deploy again

# need valid redis for migrate
run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"

run "sudo monit stop all -g resque_photos"
#if %x[ps axo command|grep resque[-]|grep -c Forked].to_i > 0
#  raise "Resque Workers Working!!. I have asked them to stop when finished. Please retry deploy"
#end

#FOR WORKERS WHO WILL BE STOPPED WITH TERM TO
#if %x[ps axo command|grep resque[-]|grep -c Forked].to_i > 0 
#  raise "Resque Workers Working!!"
#else
#  run "sudo monit stop all -g fractalresque_resque"
#end


#Use Jammit gem to package css and javascript
run "bundle exec jammit"
run "rm -rf #{release_path}/public/javascripts"
run "rm -rf #{release_path}/public/stylesheets"
