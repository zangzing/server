require 'factory_girl'
require 'fileutils'

# use the bulk id generator to give us persistent ids across runs to allow
# us to use the database persistently if we choose
def next_id
  BulkIdManager.next_id_for("cache_tx_generator", 1)
end

# NOTE: instead of using associations use the style shown below in :album
# where we use the after_build callback to create the associations.  We do
# this because the straight associations will create a new object without wiring
# an object graph together properly.  For instance, if you create a photo that
# in turn has an association to a user and album when the album is created it
# also has an association with a user so you end up with 2 different user objects
#
# By using the technique of calling create explicitly in the after_build callback
# we can wire things up properly because we are able to test in each factory
# whether we have already been passed the object or need to create a new one.  The
# end result is that you get what you expect which is a photo with 1 album, and 1 user
#

# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |this|
  this.first_name          {"Juan_#{next_id}"}
  this.last_name           {"Penas_#{next_id}"}
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
  this.name        Album::DEFAULT_NAME
#  album.association :user
  this.after_build do |this, proxy|
    this.user ||= Factory.create(:user)
  end
end

Factory.define :group do |this|
  this.name          {"Group #{next_id}"}
  this.after_build do |this, proxy|
    this.user ||= Factory.create(:user)
  end
end

Factory.define :group_member do |this|
  this.after_build do |this, proxy|
    this.group ||= Factory.create(:group)
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
    this.user ||= Factory.create(:user)
    this.album ||= Factory.create(:album, :user => this.user)
    this.upload_batch = UploadBatch.get_current_and_touch( this.user.id, this.album.id )
  end
end

Factory.define :full_photo, :parent => :photo do |this|
  this.after_build do |this, proxy|
    if this.temp_url.nil?
      # if you set temp_url we will use that as the file to upload
      # otherwise we use a default file
      source_path = spec_dir + "/assets/test_photo.jpg"
    else
      source_path = this.temp_url
    end
    this.caption ||= "Full Photo #{next_id}"
    this.source_guid ||= "rspec_full_photo: #{UUIDTools::UUID.random_create}"
    this.source ||= "rspec"
    dest_path = "#{Dir.tmpdir}/#{Time.now.to_f}-#{rand(999999)}"
    FileUtils.copy_file(source_path, dest_path, true)
    this.file_to_upload = dest_path
  end
end

Factory.define :address, :class => Address do |this|
  this.firstname  Faker::Name.first_name
  this.lastname   Faker::Name.last_name
  this.address1   Faker::Address.street_address
  this.city       Faker::Address.city
  this.state_id   276110813
  this.zipcode    Faker::Address.zip_code
  this.phone      Faker::PhoneNumber.phone_number
  this.country_id 214
end

Factory.define :order, :class => Order do |this|
  this.after_build do |this, proxy|
      this.user ||= Factory.create(:user)
      this.email ||= this.user.email
      this.bill_address  ||= Factory.create(:address)
  end
end




#Factory.define :upload_batch do |this|
#  this.after_build do |this, proxy|
#    this.user ||= Factory.create(:user)
#    this.album ||= Factory.create(:album, :user => this.user)
#  end
#end