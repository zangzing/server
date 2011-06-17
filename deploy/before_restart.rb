# This is an EngineYard deploy hook.
# It is executed after the whole deploy process is finished and the application is ready to be restarted

# Symlink nginx conf files

# Symlink Resque Files

# remove and symlink the various shared config files - the shared path
# file was set up by custom chef script
run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
run "ln -nfs #{shared_path}/config/resque.yml #{release_path}/config/resque.yml"
run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
run "ln -nfs #{shared_path}/config/memcached_custom.yml #{release_path}/config/memcached.yml"

# Restart Resque workers
run "sudo monit restart all -g resque_photos"

# clear out the nginx cache
run "find /tmp/nginx/cache -type f -exec rm {} \\;"

# now run the migration - we do this here to avoid downtime
# only need this to run on one machine
if ['solo', 'app_master'].include?(node["instance_role"])
  run "RAILS_ENV=#{environment()} bundle exec rake db:migrate"
end

# make sure v3homepage is deployed with the current tag, technically we really only
# need this to run when we have newly added machines but there is really no way to know
# so we run it each time.  The downside is that this is a fairly lengthy operation
# We only need to run on one instance, so use the app_master or solo - they are mutually
# exclusive
if ['solo', 'app_master'].include?(node["instance_role"])
  run "rails runner -e #{environment()} HomepageManager.deploy_homepage_current_tag_async"
end


#ALL DONE! Restart the App.
