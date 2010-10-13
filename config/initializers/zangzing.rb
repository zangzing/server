fname = "/home/deploy/dna.json"
msg = []
msg << "=> ZangZing Initializer"
if File.exists?( fname )
  dna =  ActiveSupport::JSON.decode( File.read( fname ))
  APPLICATION_HOST = dna['engineyard']['environment']['apps'][0]['vhosts'][0]['domain_name']+':80'
  msg << "      Deployment information from : "+fname
  msg << "      ZangZing Server deployed at : EngineYard"
  msg << "      EngineYard environment      : "+dna['engineyard']['environment']['name']
  msg << "      Host public AWS name        : " + dna['engineyard']['environment']['instances'][0]['public_hostname']
  msg << "      Rails environment           : " + dna['engineyard']['environment']['framework_env']
  msg << "      Domain Name                 : " + APPLICATION_HOST.split(':')[0]
  msg << "      Port                        : " + APPLICATION_HOST.split(':')[1]
  msg << "      Source Repo                 : " + dna['engineyard']['environment']['apps'][0]['repository_name']
  msg << "      Source Repo Branch          : " + dna['engineyard']['environment']['apps'][0]['branch']
  msg << "      Source Version (from git)   : " + ZANGZING_VERSION
else
  if ENV['APPLICATION_HOST']
    APPLICATION_HOST=ENV['APPLICATION_HOST'];
    msg << "      Deployment information from : Environment Variables"
  else
    msg << "      Deployment information from : Default Values in environment.rb"
  end
   msg << "      Rails environment           : " + Rails.env
   msg << "      Domain Name                 : " + APPLICATION_HOST.split(':')[0]
   msg << "      Port                        : " + APPLICATION_HOST.split(':')[1]
   msg << "      Source Version (from git)   : " + ZANGZING_VERSION
end
msg = msg.flatten.compact.join("\n")
puts msg
Rails.logger.info msg
