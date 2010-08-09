class ChangeIdentityCredentialsSize < ActiveRecord::Migration
  def self.up
    #Column size was not enough to store Kodak cookies
    execute 'ALTER TABLE zz_server.identities CHANGE COLUMN credentials credentials VARCHAR(400) DEFAULT NULL'
  end

  def self.down
    execute 'ALTER TABLE zz_server.identities CHANGE COLUMN credentials credentials VARCHAR(255) DEFAULT NULL'
  end
end
