# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.first_name          "Juan"
  user.last_name           "Penas"
  user.sequence(:username) {|n| "user#{n}"}
  user.sequence(:email)    {|n| "user#{n}@test.zangzing.com"}
  user.password            "password"
  user.perishable_token    {|n| "token-#{n}"}
end

# created a Factory sequence
Factory.sequence :email do |n|
  "person-#{n}@example.com"
end


Factory.define :album do |album|
  album.name        "Foo bar album"
  album.association :user
end


Factory.define :album_with_photos, :parent => :album do |album|
  album.name        "Foo bar album"
  album.association :user
  album.after_create do |a|
    a.photos = [
                  Factory(:photo, :album => a),
                  Factory(:photo, :album => a),
                  Factory(:photo, :album => a)
              ]
  end

end




Factory.define :photo do |photo|
  photo.association :album
  photo.association :user
  photo.association :upload_batch
  photo.sequence(:id) {|n| n}
end

Factory.define :upload_batch do |upload_batch|
  upload_batch.association :album
  upload_batch.association :user
end