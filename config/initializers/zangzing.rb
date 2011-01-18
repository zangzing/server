
silence_warnings do #To avoid warning of overwriting constant
  # SET VERSION
  git_cmd = File.join(*[ENV['IMAGEMAGICK_PATH'], "git"].compact)
  zconfig = Server::Application.config
  zconfig.zangzing_version = `#{git_cmd} describe` || 'UNKNOWN'

  zz_deploy_environment = nil

  # GET AND SET ENVIRONMENT
  fname = "/etc/chef/dna.json"
  dna = nil
  if File.exists?( fname )
    dna =  ActiveSupport::JSON.decode( File.read( fname ))
  end
  zz_deploy_environment = ZZDeployEnvironment.new(dna)
  zconfig.deploy_environment = zz_deploy_environment # make it availble for use later
  
  msg = []
  msg << "=> ZangZing Initializer"
  msg << "      Task started at             : " + Time.now.to_s
  msg << "      Tempfile Directory          : " + Dir.tmpdir
  msg << "      Path                        : " + ENV['PATH']
  msg << "      Resque_CPU_host             : " + zz_deploy_environment.resque_cpu_host_name
  msg << "      Redis_host                  : " + zz_deploy_environment.redis_host_name
  if File.exists?( fname )
    zconfig.application_host = dna['engineyard']['environment']['apps'][0]['vhosts'][0]['domain_name']
    zconfig.album_email_host="#{zconfig.application_host.split('.')[0]}-post.zangzing.com"
    msg << "      Deployment information from : "+fname
    msg << "      ZangZing Server deployed at : EngineYard"
    msg << "      EngineYard environment      : "+dna['engineyard']['environment']['name']
    msg << "      Host public AWS name        : " + dna['engineyard']['environment']['instances'][0]['public_hostname']
    msg << "      Rails environment           : " + dna['engineyard']['environment']['framework_env']
    msg << "      Host                        : " + zconfig.application_host
    msg << "      Album Email Host            : " + zconfig.album_email_host
    msg << "      Source Repo                 : " + dna['engineyard']['environment']['apps'][0]['repository_name']
    msg << "      Source Repo Branch          : " + dna['engineyard']['environment']['apps'][0]['branch']
    msg << "      Source Version (from git)   : " + zconfig.zangzing_version
  else
    zz_deploy_environment = ZZDeployEnvironment.new(nil)
    if ENV['Server::Application.config.application_host']
      zconfig.application_host=ENV['Server::Application.config.application_host'];
      zconfig.album_email_host="#{zconfig.application_host.split('.')[0]}-post.zangzing.com"
      msg << "      Deployment information from : Environment Variables"
    else
      msg << "      Deployment information from : Default Values in environment.rb"
    end
    msg << "      Rails environment           : " + Rails.env
    msg << "      Host                        : " + zconfig.application_host
    msg << "      Album Email Host            : " + zconfig.album_email_host
    msg << "      Source Version (from git)   : " + zconfig.zangzing_version
  end
  msg = msg.flatten.compact.join("\n")
  puts msg
  Rails.logger.info msg
end