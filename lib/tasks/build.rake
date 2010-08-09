
#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#


desc "Build environment, setup applications and run all tests"
task :build =>['build:bundle','build:rspec']


namespace :build do
  desc "Run bundle install to create environment"
  task :bundle do
    begin
      # Try to require the preresolved locked set of gems.
      require File.dirname(__FILE__) + "/../.bundle/environment"
    rescue Exception=>e
      # Fall back on doing an unlocked resolve at runtime.
      if (!system("bundle install"))
        puts $?
      end
    end
    require File.dirname(__FILE__) + "/../../.bundle/environment"
  end

  desc "Run all rspec tests in spec"
  task :rspec do
    Rake::Task['spec:models'].invoke
  end
end