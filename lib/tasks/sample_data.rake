begin
  require 'faker'

  namespace :db do
    desc "Drop DB and fill it with sample test data"
    task :sample => :environment do
      Rake::Task['build:db'].invoke
      SampleDataLoader.new.create_all
    end
  end
rescue LoadError
  namespace :db do
    desc "Faker gem not found. db:sample not possible"
    task :sample do
      puts "Faker gem not found. db:sample not possible"
    end
  end
end

