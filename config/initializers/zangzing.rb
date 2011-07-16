require 'lib/cache/album/manager'

silence_warnings do #To avoid warning of overwriting constant
  zconfig = Server::Application.config
  msg = []

  # GET AND SET ENVIRONMENT
  # until we transition completely to amazon support
  # both EY and zz style dna.json
  # If we have the zz form that takes precedence
  zz_deploy_environment = ZZDeployEnvironment.env
  zconfig.deploy_environment = zz_deploy_environment # make it available for use later

  # set up command path
  cmd_path = ENV['IMAGEMAGICK_PATH']
  if (cmd_path.nil?)
    cmd_path = "/usr/bin"
    msg << " WARNING: IMAGEMAGICK_PATH WAS NOT SET, USING #{cmd_path}, MAKE SURE THIS MATCHES YOUR ENVIRONMENT"
  end
  ZZ::CommandLineRunner.command_path = cmd_path
  dna = zz_deploy_environment.node
  zz = zz_deploy_environment.zz

  # SET VERSION
  # under zz use the app deploy tag and return the abbreviated ref after the deploy tag
  ver = nil
  deploy_tag = zz[:app_deploy_tag]
  if !deploy_tag.nil?
    ver = ZZ::CommandLineRunner.run('git', "show-ref --head --abbrev #{deploy_tag}").split[0] rescue ver = nil
    ver = "#{deploy_tag}-#{ver}"
  end
  if ver.nil?
    # don't have deploy tag so do it old way via describe which is not accurate
    ver = ZZ::CommandLineRunner.run('git', 'describe') rescue zconfig.zangzing_version = "UNKNOWN"
  end
  zconfig.zangzing_version = ver

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
  if zz_deploy_environment.is_ey?
    zconfig.application_host = dna['engineyard']['environment']['apps'][0]['vhosts'][0]['domain_name']
    msg << "      ZangZing Server deployed at : EngineYard"
    msg << "      EngineYard environment      : "+dna['engineyard']['environment']['name']
    msg << "      Host public AWS name        : " + dna['engineyard']['environment']['instances'][0]['public_hostname']
    msg << "      Rails environment           : " + dna['engineyard']['environment']['framework_env']
    msg << "      Host                        : " + zconfig.application_host
    msg << "      Album Email Host            : " + zconfig.album_email_host
    msg << "      Source Repo                 : " + dna['engineyard']['environment']['apps'][0]['repository_name']
    msg << "      Source Repo Branch          : " + dna['engineyard']['environment']['apps'][0]['branch'].to_s
    msg << "      Source Version (from git)   : " + zconfig.zangzing_version
  elsif zz[:dev_machine] == false
    # deployed at amazon
    zconfig.application_host = zz[:group_config][:vhost]
    zconfig.album_email_host = zz[:group_config][:email_host]
    msg << "      ZangZing Server deployed at : Amazon"
    msg << "      Deploy Group                : "+ zz[:deploy_group_name]
    msg << "      Host public AWS name        : " + zz[:public_hostname]
    msg << "      Rails environment           : " + Rails.env
    msg << "      Host                        : " + zconfig.application_host
    msg << "      Album Email Host            : " + zconfig.album_email_host
    msg << "      Source Repo                 : " + zz[:group_config][:app_git_url]
    msg << "      Deploy Tag                  : " + zz[:app_deploy_tag]
    msg << "      Source Version (from git)   : " + zconfig.zangzing_version

  else
    # dev machine
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


  msg = msg.flatten.compact.join("\n")
  puts msg
  Rails.logger.info msg
  zconfig.action_mailer.default_url_options = {:host => zconfig.application_host }

  # initialize album cache manager
  # make a single instance of the the album cache manager
  Cache::Album::Manager.make_shared




end

