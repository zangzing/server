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
puts "-----ZZ PHOTOS_TEST_PREPARE_CONFIG------"
puts zz_base_dir
puts zz_shared_dir
puts zz_current_dir
puts zz_release_dir
puts zz_app
puts zz_role
puts zz_rails_env
puts "-----ZZ PHOTOS_TEST_PREPARE_CONFIG------"

execute "test_chef_custom_hook" do
  command "ls -al #{zz_release_dir}"
end

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
    run "cp -f #{from} #{to}"
  end
end



# stop any resque workers if downtime
if zz[:deploy_downtime]
  run "sudo monit stop all -g resque_photos"
end

# The following is only done on machines that host
# the app server.  No need to to on util machines.
if [:solo, :app_master, :app].include?(zz_role)
  # move custom assets based on deploy environment
  assets = [
      'robots.txt'
  ]
  move_assets(assets)

  #Use Jammit gem to package css and javascript
  run "bundle exec jammit"
  run "rm -rf #{zz_release_dir}/public/javascripts"
  run "rm -rf #{zz_release_dir}/public/stylesheets"
end
