# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.first_name          "Juan"
  user.last_name           "Penas"
  user.sequence(:username) {|n| "user#{n}"}
  user.sequence(:email)    {|n| "user#{n}@test.zangzing.com"}
  user.password            "password"
  user.perishable_token    {|n| "token#{n}"}
end

# created a Factory sequence
Factory.sequence :email do |n|
  "person-#{n}@example.com"
end


Factory.define :album do |album|
  album.name        "Foo bar album"
  album.association :user
end

Factory.define :photo do |photo|
  photo.association :album
  
end