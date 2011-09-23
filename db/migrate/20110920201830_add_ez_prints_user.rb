class AddEzPrintsUser < ActiveRecord::Migration
  def self.up
    user = User.new(:email => 'ezprintsuser@zangzing.com', :name => 'EZPrints EZPrints', :username => 'ezprintsuser',
            :password => 'x739iutp', :automatic => false)
    user.reset_perishable_token
    user.reset_single_access_token
    user.save!
  end

  def self.down
    user = User.find_by_username('ezprintsuser')
    user.destroy
  end
end
