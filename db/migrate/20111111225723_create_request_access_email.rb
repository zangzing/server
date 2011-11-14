class CreateRequestAccessEmail < ActiveRecord::Migration
  def self.up
    print " ----------------- Creating Request Access Email -----------------------"
    Email.create( :name   => 'request_access',  :kind => Email::TRANSACTIONAL )
  end

  def self.down
    print " ----------------- Deleting Request Access Email -----------------------"
    e = Email.find_by_name( 'request_access')
    e.destroy if e
  end
end
