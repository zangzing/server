begin

  require 'faker'

  namespace :db do
    desc "Drop DB and fill it with sample test data"
    task :populate => :environment do
      Rake::Task['build:db'].invoke

      # create 50 users
      users = []
      50.times do |n|
        name  = Faker::Name.name
        email = "example-#{n+1}@zangzing.org"
        password  = "password"
        username  = Faker::Internet.user_name+n.to_s 
        users[n]  = User.create!(:name => name,
                     :username => username, 
                     :email => email,
                     :password => password,
                     :password_confirmation => password)
      end

      # create albums for first 10 users
      User.all(:limit => 10).each do |user|
        rand(15).times do
         user.albums.create!( :name => Faker::Address.city()+' '+Faker::Address.us_state_abbr())         
        end
      end

      # create follows
      User.all(:limit => 10).each do |user|
        rand(15).times do
          Follow.factory( user, users[rand(50)]).save
          Follow.factory( users[rand(50)], user).save
        end
      end


    end
  end
rescue LoadError
  namespace :db do
    desc "Faker gem not found db:populate not available"
    task :populate do
      puts "Faker gem not found db:populate not available"
    end
  end
end
