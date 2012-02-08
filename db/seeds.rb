# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# ZANGZING USER

require 'user'
require 'identity'


# Mr ZZ must go first since he is such a popular guy that everybody likes him!
user = User.new(  {:email  => 'marketing@zangzing.com'})
user.name = 'ZangZing'
user.username = 'zangzing'
user.password = 'dud7/adds'
user.automatic = false
user.reset_perishable_token
user.reset_single_access_token
user.save!
print user.name + " User Created!\n"




user = User.new(  {:email   => 'admin@zangzing.com' })
user.name = 'ZangZing Admin'
user.username = 'zzadmin'
user.password = 'cal6:cars'
user.automatic = false
user.reset_perishable_token
user.reset_single_access_token
user.save!
SystemRightsACL.singleton.add_user(user, SystemRightsACL::ADMIN_ROLE)
print user.name + " User Created!\n"

# ZANGZING  AGENT CLIENT APPLICATION TOKEN
# WARNING: This values are in all desktop agents, do not loose or change them them
agent = user.client_applications.build( {:name =>         'ZangZing Agent V1.0',
                                         :url  =>         'http://www.zangzing.com',
                                         :support_url =>  'http://www.zangzing.com',
                                         :callback_url => 'http://www.zangzing.com' })
agent.update_attribute(:key, 'duGvzn35vc14QvspWUPk')
agent.update_attribute(:secret, 'coNkUA3exUpNA8OBGhK2hDKBur3OQnAvDZyZfcbd')
print "ZangZing Agent Client Application token created!\n"

potd = user.client_applications.create( { :name =>         'POTD V1.0 Beta List',
                                          :url  =>         'http://www.zangzing.com/potd',
                                          :support_url =>  'http://www.zangzing.com/potd',
                                          :callback_url => 'http://www.zangzing.com/potd' })
potd.update_attribute(:key, 'usNJuvEb4eDML5XzCCP1')
potd.update_attribute(:secret, 'PcHdlhsMKkJ0765rMQ8zsv3Nr8kcqIzR7YQWLjdp')
print "POTD Client Application token created!\n"

