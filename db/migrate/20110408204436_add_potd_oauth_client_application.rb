class AddPotdOauthClientApplication < ActiveRecord::Migration
  def self.up
    # POTD CLIENT APPLICATION TOKEN
    # WARNING: This values are used by the potd application do not loose or change them them
    user = User.find_by_username('zzadmin')
    unless user.nil?
      potd = user.client_applications.create( { :name =>         'POTD V1.0 Beta List',
                                                :url  =>         'http://www.zangzing.com/potd',
                                                :support_url =>  'http://www.zangzing.com/potd',
                                                :callback_url => 'http://www.zangzing.com/potd' })
      potd.update_attribute(:key, 'usNJuvEb4eDML5XzCCP1')
      potd.update_attribute(:secret, 'PcHdlhsMKkJ0765rMQ8zsv3Nr8kcqIzR7YQWLjdp')
      print "POTD Client Application token created!\n"
    end
  end

  def self.down
  end
end
