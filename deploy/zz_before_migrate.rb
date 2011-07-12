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
