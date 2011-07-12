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
#
puts "-----ZZ TEST_BEFORE_MIGRATE------"
puts zz[:app_name]
puts zz_base_dir
puts zz_shared_dir
puts zz_current_dir
puts zz_release_dir
puts "-----ZZ TEST_BEFORE_MIGRATE------"

execute "test_chef_custom_hook" do
  command "ls -al #{zz_release_dir}"
end

# force an error
x = nil
x.failure
