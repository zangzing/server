# this is where custom configuration can take place
# you can use either inline ruby code or chef recipes
# such as execute, file, etc.  You can't use chef recipes
# that require files to exist such as template.  For that you
# can add directly to the zz-chef-repo if needed.
#
# We only have one hook now to keep things simple.  This
# hook runs right before any migrations have taken place and
# before we have made the release directory current.  You have
# access to the full set of configuration information via the
# zz variable.  See the file /data/app_name/shared/config/zz_app_dna.json
# to see what information is available.  As a shortcut you also
# have direct access to the following variables.  Generally you
# should only use zz_release_dir and zz_shared_dir when referencing
# the location of your deployed code.
#
#puts zz[:app_name]
#puts zz_base_dir
#puts zz_shared_dir
#puts zz_current_dir
#puts zz_release_dir
#puts zz_app  (symbol)
#puts zz_role (symbol)
#puts zz_rails_env (symbol)
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

# put custom assets in place based on environment for app servers
if [:solo, :app_master, :app].include?(zz_role)
  assets = [
      'robots.txt'
  ]
  move_assets(assets)
end


#Use Jammit gem to package css and javascript
run "bundle exec jammit"
run "rm -rf #{zz_release_dir}/public/javascripts"
run "rm -rf #{zz_release_dir}/public/stylesheets"
