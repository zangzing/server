require 'faker'

namespace :db do
  desc "Drop DB and fill it with sample test data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    admin = User.create!(:name => "ZZ Admin User",
                 :email => "example-zzadmin@zangzing.org",
                 :password => "foobar",
                 :password_confirmation => "foobar")
    admin.update_attribute( :role, :admin )

    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@zangzing.org"
      password  = "password"
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password)
    end
    User.all(:limit => 10).each do |user|
          10.times do
            user.albums.create!(:name => Faker::Address.city()+' '+Faker::Address.us_state_abbr())
          end
    end
  end
end

