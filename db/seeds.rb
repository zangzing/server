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
user = User.new(  {:name                   => 'ZangZing',
                      :username               => 'zangzing',
                      :email                  => 'marketing@zangzing.com',
                      :password               => 'dud7/adds',
                      :password_confirmation  => 'dud7/adds'})
user.reset_perishable_token
user.reset_single_access_token
#user.update_attribute(:role, 'admin')
user.save
print user.name + " User Created!\n"




user = User.new(  {:name                   => 'ZangZing Admin',
                      :username               => 'zzadmin',
                      :email                  => 'admin@zangzing.com',
                      :password               => 'cal6:cars',
                      :password_confirmation  => 'cal6:cars'})
user.reset_perishable_token
user.reset_single_access_token
user.update_attribute(:role, 'admin')
user.save
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


