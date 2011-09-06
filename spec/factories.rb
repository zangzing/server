require 'factory_girl'

# use the bulk id generator to give us persistent ids across runs to allow
# us to use the database persistently if we choose
def next_id
  BulkIdManager.next_id_for("cache_tx_generator", 1)
end


# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |this|
  this.first_name          "Juan"
  this.last_name           "Penas"
  this.username            {"user#{next_id}"}
  this.email                {"user#{next_id}@test.zangzing.com"}
  this.password            "password"
  this.perishable_token    {"token-#{next_id}"}
end

# created a Factory sequence
Factory.sequence :email do |n|
  "person-#{next_id}@example.com"
end


Factory.define :album do |this|
  this.name        "Foo bar album"
#  album.association :user
  this.after_build do |this, proxy|
    this.user ||= Factory.create(:user)
  end
end


Factory.define :comment do |this|
  this.text "this is a comment"
  this.after_build do |this, proxy|
    this.user ||= Factory.create(:user)
  end
end


Factory.define :photo_commentable, :class => Commentable do |this|
  this.after_build do |this, proxy|
    this.subject ||= Factory.create(:photo)
  end
end

Factory.define :photo_comment, :class => Comment do |this|
  this.text "this is a comment"
  this.after_build do |this, proxy|
    this.user ||= Factory.create(:user)
    this.commentable ||= Factory.create(:photo_commentable)
  end
end

Factory.define :photo do |this|
  this.id                  {Photo.get_next_id}
  this.after_build do |this, proxy|
    this.user = Factory.create(:user) if this.user.nil?
    this.album = Factory.create(:album, :user => this.user) if this.album.nil?
    this.upload_batch = Factory.create(:upload_batch, :album => this.album, :user => this.user)
  end
end

Factory.define :full_photo, :parent => :photo do |photo|
end

Factory.define :upload_batch do |this|
  this.after_build do |this, proxy|
    this.user ||= Factory.create(:user)
    this.album ||= Factory.create(:album, :user => this.user)
  end
end