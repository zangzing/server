# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                  "Juan Penas"
  user.email                 "juan@penas.com"
  user.role                  "user"
  user.password              "foobar"
  user.password_confirmation "foobar"
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