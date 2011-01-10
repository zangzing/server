# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# ZANGZING USER

require 'user'

user = User.create(  {:name                   => 'ZangZing Paying User V1.0',
                      :username               => 'zangzing',    
                      :email                  => 'user@zangzing.com',
                      :password               => 'password',
                      :password_confirmation  => 'password'})
user.update_attribute(:role, 'admin')
print "ZangZing User Created!\n"

# ZANGZING  AGENT CLIENT APPLICATION TOKEN
# WARNING: This values are in all desktop agents, do not loose or change them them
agent = user.client_applications.build( {:name =>         'ZangZing Agent V1.0',
                                         :url  =>         'http://www.zangzing.com',
                                         :support_url =>  'http://www.zangzing.com',
                                         :callback_url => 'http://www.zangzing.com' })
agent.update_attribute(:key, 'duGvzn35vc14QvspWUPk')
agent.update_attribute(:secret, 'coNkUA3exUpNA8OBGhK2hDKBur3OQnAvDZyZfcbd')
print "ZangZing Agent Client Application token created!\n"
