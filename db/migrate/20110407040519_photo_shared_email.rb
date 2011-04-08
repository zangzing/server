class PhotoSharedEmail < ActiveRecord::Migration
  def self.up
    print "Creating Phot Shared Email...\n"
    photo_shared        = Email.create( :name => :photo_shared)
  end

  def self.down
  end
end
