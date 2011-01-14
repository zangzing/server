
silence_warnings do #To avoid warning of overwriting constant
  # SET VERSION
  git_cmd = File.join(*[ENV['IMAGEMAGICK_PATH'], "git"].compact)
  Server::Application.config.zangzing_version = `#{git_cmd} describe` || 'UNKNOWN'

  # GET AND SET ENVIRONMENT
  fname = "/home/deploy/dna.json"
  msg = []
  msg << "=> ZangZing Initializer"
  msg << "      Task started at             : " + Time.now.to_s
  msg << "      Tempfile Directory          : " + Dir.tmpdir
  msg << "      Path                        : " + ENV['PATH']

  if File.exists?( fname )
    dna =  ActiveSupport::JSON.decode( File.read( fname ))
    Server::Application.config.application_host = dna['engineyard']['environment']['apps'][0]['vhosts'][0]['domain_name']
    Server::Application.config.album_email_host="#{Server::Application.config.application_host.split('.')[0]}-post.zangzing.com"
    msg << "      Deployment information from : "+fname
    msg << "      ZangZing Server deployed at : EngineYard"
    msg << "      EngineYard environment      : "+dna['engineyard']['environment']['name']
    msg << "      Host public AWS name        : " + dna['engineyard']['environment']['instances'][0]['public_hostname']
    msg << "      Rails environment           : " + dna['engineyard']['environment']['framework_env']
    msg << "      Host                        : " + Server::Application.config.application_host
    msg << "      Album Email Host            : " + Server::Application.config.album_email_host
    msg << "      Source Repo                 : " + dna['engineyard']['environment']['apps'][0]['repository_name']
    msg << "      Source Repo Branch          : " + dna['engineyard']['environment']['apps'][0]['branch']
    msg << "      Source Version (from git)   : " + Server::Application.config.zangzing_version
  else
    if ENV['Server::Application.config.application_host']
      Server::Application.config.application_host=ENV['Server::Application.config.application_host'];
      Server::Application.config.album_email_host="#{Server::Application.config.application_host.split('.')[0]}-post.zangzing.com"
      msg << "      Deployment information from : Environment Variables"
    else
      msg << "      Deployment information from : Default Values in environment.rb"
    end
    msg << "      Rails environment           : " + Rails.env
    msg << "      Host                        : " + Server::Application.config.application_host
    msg << "      Album Email Host            : " + Server::Application.config.album_email_host
    msg << "      Source Version (from git)   : " + Server::Application.config.zangzing_version
  end
  msg = msg.flatten.compact.join("\n")
  puts msg
  Rails.logger.info msg
end