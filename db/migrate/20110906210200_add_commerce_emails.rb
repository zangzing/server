class AddCommerceEmails < ActiveRecord::Migration
  def self.up
    print " ----------------- Creating Commerce Emails -----------------------"
    Email.create( :name   => 'order_confirmed',  :kind => Email::TRANSACTIONAL )
    Email.create( :name   => 'order_cancelled',   :kind => Email::TRANSACTIONAL )
    Email.create( :name   => 'order_shipped',  :kind => Email::TRANSACTIONAL )
  end

  def self.down
    print " ----------------- Deleting Commerce Emails -----------------------"
    e = Email.find_by_name( 'order_confirmed')
    e.destroy if e
    e = Email.find_by_name( 'order_cancelled')
    e.destroy if e
    e = Email.find_by_name( 'order_shipped')
    e.destroy if e
  end
end
