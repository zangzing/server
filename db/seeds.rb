# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# ZANGZING USER
User.connection.execute("INSERT INTO users (id,first_name,last_name,email,role,style,crypted_password,password_salt,persistence_token,single_access_token,perishable_token) VALUES(0,'ZangZing','Agent V1.0','agent0@zangzing.com','admin','white','7db04ebdd4b661527736499f67f501f2502c9978b86297571471b3a96cc577e0fbd71cfb0ff816ecd0a5356ade81f203dd8194ded6f4478318f87afba6c745a5','-uvYtqvtO-pFGkciLlBC','3ba39abf6446fd7746f0eb9e5fcc0f95a75254464bec7aa8b03b3947539935579ed613c08bcac1fcb3652c982609ef318b9e94120e857b51ae58b969915a34c1','sTE4ojQ3rwP8ETMnfRpt','uOk3-T-7_BVCd8l2F4EI');")
print "ZangZing User Created!\n"

# ZANGZING  AGENT CLIENT APPLICATION TOKEN
# This values are in all the agents, do not loose or change them them
User.connection.execute("INSERT INTO client_applications (id,user_id,name,url,support_url,callback_url,`key`,secret) VALUES(0,0,'ZangZing Agent V1.0','http://www.zangzing.com','http://www.zangzing.com','http://www.zangzing.com','duGvzn35vc14QvspWUPk','coNkUA3exUpNA8OBGhK2hDKBur3OQnAvDZyZfcbd');")
print "ZangZing Agent Client Application token created!\n"
