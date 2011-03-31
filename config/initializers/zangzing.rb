require 'lib/zz/mailchimp'
require 'lib/album_cache_manager'

silence_warnings do #To avoid warning of overwriting constant
  zconfig = Server::Application.config
  msg = []

  # GET AND SET ENVIRONMENT
  fname = "/home/deploy/dna.json"
  dna = nil
  if File.exists?( fname )
    dna =  ActiveSupport::JSON.decode( File.read( fname ))
  end
  zz_deploy_environment = ZZDeployEnvironment.new(dna)
  zconfig.deploy_environment = zz_deploy_environment # make it available for use later

  # set up command path
  cmd_path = ENV['IMAGEMAGICK_PATH']
  if (cmd_path.nil?)
    cmd_path = "/usr/bin"
    msg << " WARNING: IMAGEMAGICK_PATH WAS NOT SET, USING #{cmd_path}, MAKE SURE THIS MATCHES YOUR ENVIRONMENT"
  end
  ZZ::CommandLineRunner.command_path = cmd_path

  # SET VERSION
  zconfig.zangzing_version = ZZ::CommandLineRunner.run('git', 'describe') rescue zconfig.zangzing_version = "UNKNOWN"

  # set rails asset id
  if Rails.env != 'development'
    ENV["RAILS_ASSET_ID"] = zconfig.zangzing_version.strip
  end

  msg << "=> ZangZing Initializer"
  msg << "      Task started at             : " + Time.now.to_s
  msg << "      Tempfile Directory          : " + Dir.tmpdir
  msg << "      Command Path                : " + ZZ::CommandLineRunner.command_path
  msg << "      Path                        : " + ENV['PATH']
  msg << "      Resque_CPU_hosts            : " + zz_deploy_environment.resque_cpu_host_names.to_s
  msg << "      Redis_host                  : " + zz_deploy_environment.redis_host_name
  msg << "      Memcached hosts             : " + MemcachedConfig.server_list.to_s
  if File.exists?( fname )
    zconfig.application_host = dna['engineyard']['environment']['apps'][0]['vhosts'][0]['domain_name']
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
    if ENV['APPLICATION_HOST']
      zconfig.application_host=ENV['APPLICATION_HOST']
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

  #Initialize MailChimp
  begin
    ZZ::MailChimp.load_setup()
    msg << "      MailChimp Status            : " + ZZ::MailChimp.ping()
  rescue Exception => e
    msg << "      MailChimp Status            :  ERROR ERROR - " + e.message
  end

  msg = msg.flatten.compact.join("\n")
  puts msg
  Rails.logger.info msg
  zconfig.action_mailer.default_url_options = {:host => zconfig.application_host }

  # initialize album cache manager
  # make a single instance of the the album cache manager
  AlbumCacheManager.make_shared


end

