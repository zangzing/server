# Bitly API Setup
Bitly.use_api_version_3

silence_warnings do #To avoid warning of overwriting constant
  # SET VERSION
  git_cmd = File.join(*[ENV['IMAGEMAGICK_PATH'], "git"].compact)
  ZANGZING_VERSION = `#{git_cmd} describe` || 'UNKNOWN'

  # GET AND SET ENVIRONMENT
  fname = "/home/deploy/dna.json"
  msg = []
  msg << "=> ZangZing Initializer"
  if File.exists?( fname )
    dna =  ActiveSupport::JSON.decode( File.read( fname ))
    APPLICATION_HOST = dna['engineyard']['environment']['apps'][0]['vhosts'][0]['domain_name']
    ALBUM_EMAIL_HOST="#{APPLICATION_HOST.split('.')[0]}-post.zangzing.com"
    msg << "      Deployment information from : "+fname
    msg << "      ZangZing Server deployed at : EngineYard"
    msg << "      EngineYard environment      : "+dna['engineyard']['environment']['name']
    msg << "      Host public AWS name        : " + dna['engineyard']['environment']['instances'][0]['public_hostname']
    msg << "      Rails environment           : " + dna['engineyard']['environment']['framework_env']
    msg << "      Host                        : " + APPLICATION_HOST
    msg << "      Album Email Host            : " + ALBUM_EMAIL_HOST
    msg << "      Source Repo                 : " + dna['engineyard']['environment']['apps'][0]['repository_name']
    msg << "      Source Repo Branch          : " + dna['engineyard']['environment']['apps'][0]['branch']
    msg << "      Source Version (from git)   : " + ZANGZING_VERSION
  else
    if ENV['APPLICATION_HOST']
      APPLICATION_HOST=ENV['APPLICATION_HOST'];
      ALBUM_EMAIL_HOST="#{APPLICATION_HOST.split('.')[0]}-post.zangzing.com"
      msg << "      Deployment information from : Environment Variables"
    else
      msg << "      Deployment information from : Default Values in environment.rb"
    end
    msg << "      Rails environment           : " + Rails.env
    msg << "      Host                        : " + APPLICATION_HOST
    msg << "      Album Email Host            : " + ALBUM_EMAIL_HOST
    msg << "      Source Version (from git)   : " + ZANGZING_VERSION
  end
  msg = msg.flatten.compact.join("\n")
  puts msg
  Rails.logger.info msg
end