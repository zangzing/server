class PhotoSharedEmail < ActiveRecord::Migration
  def self.up
    print "Creating Phot Shared Email...\n"

    beta_invite         = Email.create( :name => :beta_invite)
    photo_shared        = Email.create( :name => :photo_shared)
  end

  def self.down
  end
end
