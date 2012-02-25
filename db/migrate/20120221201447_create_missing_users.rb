class CreateMissingUsers < ActiveRecord::Migration
  def self.up
    User.reset_column_information

    u = User.find_by_username('zzmarketing')
    if u.nil?
      user = User.new(:email => 'marketinguser@zangzing.com', :name => 'ZangZing Marketing', :username => 'zzmarketing',
              :password => 'x739iutp', :automatic => false)
      user.reset_perishable_token
      user.reset_single_access_token
      user.save!
    end

    u = User.find_by_username('ezprintsuser')
    if u.nil?
      user = User.new(:email => 'ezprintsuser@zangzing.com', :name => 'EZPrints EZPrints', :username => 'ezprintsuser',
              :password => 'x739iutp', :automatic => false)
      user.reset_perishable_token
      user.reset_single_access_token
      user.save!
    end

  end

  def self.down
  end
end
