# This is an EngineYard deploy hook. 
# It is executed before the db is migrated. It is the earliest deployment hook
#
# From: http://docs.engineyard.com/appcloud/howtos/configure-and-deploy-resque#redis-configuration

def move_assets(assets)
  env = environment()
  puts "Deploy environment is " + env

  asset_dir = release_path() + "/public"
  puts "Asset Dir is " + asset_dir


  assets.each do |asset|
    # env-assetname is the form, if the file is not
    # found we ignore and leave whatever was there in place
    # so you can have a default file
    from = "#{asset_dir}/#{asset}-#{env}"
    to = asset_dir + "/" + asset
    run "cp -f #{from} #{to}"
  end
end

# put custom assets in place based on environment for app servers
if ['solo', 'app_master', 'app'].include?(node["instance_role"])
  assets = [
      'robots.txt'
  ]
  move_assets(assets)
end


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
