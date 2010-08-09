
#
#   � 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

ENV_DB_CONFIG_FILE=  "/data/zangzing/shared/config/database.yml"
WORK_DB_CONFIG_FILE= "../../config/database.yml"

desc "Build environment, setup applications and run all tests"
task :build =>['build:db','build:rspec']

namespace :build do

  desc "Copy DB credentials from env and create config file. Setup DB"
  task :db do
       #open deploy.rb get db password and setup database.yml
       config_opts = YAML.load_file(ENV_DB_CONFIG_FILE)[RAILS_ENV].symbolize_keys
       password=config_opts[:password]
       print password
       dev_opts= {'adapter'  => 'mysql',
              'database' => 'server_development',
              'username' => 'root',
              'password' => password,
              'host'     => 'localhost'}
       test_opts= {:adapter  => 'mysql',
              'database' => 'server_test',
              'username' => 'root',
              'password' => password,
              'host'     => 'localhost'}
       db_options = {'development' => dev_opts, 'test' => test_opts }
       File.open( WORK_DB_CONFIG_FILE, 'w' ) do |out|
            YAML.dump( db_options, out )
       end
       Rake::Task['db:migrate'].invoke
       Rake::Task['db:setup'].invoke
  end  

  desc "Run all rspec tests in spec"
  task :rspec do
    Rake::Task['spec:models'].invoke
  end
end