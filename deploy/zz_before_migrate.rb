# this is where custom configuration can take place
# you can use either inline ruby code or chef recipes
# such as execute, file, etc.  You can't use chef recipes
# that require files to exist such as template.  For that you
# can add directly to the zz-chef-repo if needed.
#
# This hook is run right before the migrate.  At this point
# we have not yet symlinked the release directory to current so
# if something fails there should be no impact on the running
# server.
#
# You have access to the full set of configuration information via the
# zz variable.  See the file /data/app_name/shared/config/zz_app_dna.json
# to see what information is available.  As a shortcut you also
# have direct access to the following variables.  Generally you
# should only use zz_release_dir and zz_shared_dir when referencing
# the location of your deployed code.
#
#puts zz_base_dir
#puts zz_shared_dir
#puts zz_current_dir
#puts zz_release_dir
#puts zz_app  (symbol)
#puts zz_role (symbol)
#puts zz_rails_env (symbol)
#
# You can access all of the configuration information via
# the zz method.  So for instance to get the instance id you
# would do:
# zz[:instance_id]
#
#
puts "-----ZZ PHOTOS_TEST_BEFORE_MIGRATE------"
puts zz_base_dir
puts zz_shared_dir
puts zz_current_dir
puts zz_release_dir
puts zz_app
puts zz_role
puts zz_rails_env
puts "-----ZZ PHOTOS_TEST_BEFORE_MIGRATE------"

# sample code showing use of chef resource
#execute "test_chef_custom_hook" do
#  command "ls -al #{zz_release_dir}"
#end

def move_assets(assets)
  env = zz_rails_env
  puts "Deploy environment is #{env}"

  asset_dir = zz_release_dir + "/public"
  puts "Asset Dir is #{asset_dir}"


  assets.each do |asset|
    # env-assetname is the form, if the file is not
    # found we ignore and leave whatever was there in place
    # so you can have a default file
    from = "#{asset_dir}/#{asset}-#{env}"
    to = asset_dir + "/" + asset
    run "cp -f #{from} #{to}; true" # the ; true is to cause chef to ignore errors since we don't care if doesn't exist
  end
end



# stop any resque workers if downtime
if zz[:deploy_downtime]
  # stop the resque workers, do not use monit directly since
  # it is very slow (on the order of minutes) to cycle through all
  # of them.
  #
  run "/usr/bin/zzscripts/photos_resque_stop_all"
end

# The following is only done on machines that host
# the app server.  No need to do on util machines.
if [:solo, :app_master, :app].include?(zz_role)
  # move custom assets based on deploy environment
  assets = [
      'robots.txt'
  ]
  move_assets(assets)

  #precompile less
  run "cd public/stylesheets/store/lib; bundle exec lessc bootstrap.less > ../bootstrap.css; cd -"
  
  #Use Jammit gem to package css and javascript
  run "bundle exec jammit"
  run "rm -rf #{zz_release_dir}/public/javascripts"
  run "rm -rf #{zz_release_dir}/public/stylesheets"
  run "rm -rf #{zz_release_dir}/public/sandbox"
end


# make sure v3homepage is deployed with the current tag, technically we really only
# need this to run when we have newly added machines but there is really no way to know
# so we run it each time.  The downside is that this is a fairly lengthy operation
# We only need to run on one instance, so use the app_master or solo - they are mutually
# exclusive
#todo - turn this back on after first production deploy, or move to before_restart
if [:solo, :app_master].include?(zz_role)
  run "bundle exec rails runner -e #{zz_rails_env} HomepageManager.deploy_homepage_current_tag_async"
end
