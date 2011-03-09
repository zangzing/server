# This is an EngineYard deploy hook.
# It is executed after the whole deploy process is finished and the application is ready to be restarted
def move_assets
  assets = [
      'robots.txt'
  ]

  env = environment()
  puts "Deploy environment is " + env

  asset_dir = current_path() + "/public"
  puts "Asset Dir is " + asset_dir


  assets.each do |asset|
    # env-assetname is the form, if the file is not
    # found we ignore and leave whatever was there in place
    # so you can have a default file
    from = asset_dir + "/" + env + "-" + asset
    to = asset_dir + "/" + asset
    run "cp -f #{from} #{to}"
  end
end


#Use Jammit gem to package css and javascript
run "bundle exec jammit"
run "rm -rf #{release_path}/public/javascripts"
run "rm -rf #{release_path}/public/stylesheets"

# Symlink nginx conf files

# Symlink Resque Files

# remove and symlink resque.yml with proper location of redis server - the shared path
# file was set up by custom chef script
run "ln -nfs #{shared_path}/config/resque.yml #{release_path}/config/resque.yml"
run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"

# Restart Resque workers
run "sudo monit restart all -g resque_photos"

# clear out the nginx cache
run "find /tmp/nginx/cache -type f -exec rm {} \\;"

# put custom assets in place based on environment
move_assets
#ALL DONE! Restart the App.
