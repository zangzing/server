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
puts "-----ZZ TEST_BEFORE_MIGRATE------"
puts zz_base_dir
puts zz_shared_dir
puts zz_current_dir
puts zz_release_dir
puts zz_app
puts zz_role
puts zz_rails_env
puts "-----ZZ TEST_BEFORE_MIGRATE------"

execute "test_chef_custom_hook" do
  command "ls -al #{zz_release_dir}"
end

# make sure v3homepage is deployed with the current tag, technically we really only
# need this to run when we have newly added machines but there is really no way to know
# so we run it each time.  The downside is that this is a fairly lengthy operation
# We only need to run on one instance, so use the app_master or solo - they are mutually
# exclusive
if [:solo, :app_master].include?(zz_role)
  run "bundle exec rails runner -e #{zz_rails_env} HomepageManager.deploy_homepage_current_tag_async"
end
