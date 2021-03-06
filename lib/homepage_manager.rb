require 'zz'


# this class manages deployments of the homepage v3 web pages
# the site comes from the v3homepage repository but is managed
# directly by the photo web servers
class HomepageManager
  # do a deploy against all web server front ends
  # using the git tag specified
  def self.deploy(tag)
    # first store the deploy tag
    SystemSetting[:homepage_deploy_tag] = tag

    rpc_responses = ZZ::Async::RemoteJobWorker.remote_rpc_app_servers(self.name, 'deploy_homepage', :tag => tag)

    # got the responses, lets see if we have an error on any of them and build an exception if we do
    RPCResponse.exception_on_error(rpc_responses)

    return rpc_responses
  end

  def self.test_deploy
    deploy('origin/master')
  end

  # run the deploy for the v3 homepage
  # pull the tag from the params
  def self.deploy_homepage(params)
    tag = params[:tag]

    # set the proper directory to deploy into
    homepage_dir = ZangZingConfig.config[:v3homepage_repo_root]
    git = ZZ::CommandLineRunner.build_command("git")
    full_cmd = "cd #{homepage_dir} && #{git} fetch && #{git} checkout #{tag} 2>&1"
    result = ZZ::CommandLineRunner.run_cmd(full_cmd)
    { :stdout => result }
  end

  # do the deploy but get the tag from the system settings first, this call
  # is async because we don't want to wait around on the resque workers which might
  # not have been started since we are called during the deploy
  def self.deploy_homepage_current_tag_async
    tag = SystemSetting[:homepage_deploy_tag]
    rpc_responses = ZZ::Async::RemoteJobWorker.remote_rpc_app_servers_async(self.name, 'deploy_homepage', :tag => tag)
  end
end