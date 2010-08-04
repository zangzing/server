user = User.find_by_id(0)
unless user
  User.connection.execute("INSERT INTO users (id,name,email,admin,style,crypted_password,password_salt,persistence_token,single_access_token,perishable_token) VALUES(0,'ZangZing Agent','agent0@zangzing.com',1,'white','7db04ebdd4b661527736499f67f501f2502c9978b86297571471b3a96cc577e0fbd71cfb0ff816ecd0a5356ade81f203dd8194ded6f4478318f87afba6c745a5','-uvYtqvtO-pFGkciLlBC','3ba39abf6446fd7746f0eb9e5fcc0f95a75254464bec7aa8b03b3947539935579ed613c08bcac1fcb3652c982609ef318b9e94120e857b51ae58b969915a34c1','sTE4ojQ3rwP8ETMnfRpt','uOk3-T-7_BVCd8l2F4EI');")
  User.connection.execute("INSERT INTO client_applications (id,user_id,name,url,support_url,callback_url,key,secret) VALUES(0,0,'ZangZing Agent','http://www.zangzing.com','http://www.zangzing.com','http://www.zangzing.com','duGvzn35vc14QvspWUPk','coNkUA3exUpNA8OBGhK2hDKBur3OQnAvDZyZfcbd');")
  print "Agent consumer application key initialized\n"
end