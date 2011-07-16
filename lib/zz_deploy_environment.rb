# need this because the recursively symbolize may not be available when we are called
#require "config/initializers/hash_extensions"

# this class is a helper for the Deploy Environment setup
class ZZDeployEnvironment
  # creates an instance, looks for ey dna.json first and then
  # zz_config_dna.json

  # returns the singleton for the environment
  def self.env
    @@env ||= ZZDeployEnvironment.new
  end

  #todo Change this to only open zz_config_dna.json once we
  # are fully moved to Amazon
  #
  def initialize
    # first try EY
    node = nil
    fname = "/home/deploy/dna.json"
    if File.exists?( fname )
      node =  JSON.parse( File.read(fname))
    end
    if node.nil?
      # now try zz dna
      fname = File.dirname(__FILE__) + "/../config/zz_app_dna.json"
      node =  JSON.parse( File.read(fname))
      node.recursively_symbolize_keys!
    end
    if node.nil?
      raise "Neither dna.json for EY or zz_app_dna.json for Amazon have been defined."
    end
    @node = node
  end

  def node
    @node
  end

  def ey
    @ey ||= @node['engineyard']
  end

  def zz
    @zz ||= @node
  end

  # this entry should only exist on valid
  # zz style config
  def is_zz?
    zz[:app_config] != nil
  end

  def app_config
    @app_config ||= zz[:app_config]
  end

  def group_config
    @group_config ||= zz[:group_config]
  end

  def is_ey?
    !is_zz?
  end

  # determine if this instance should host
  # the redis server
  # true - yes we should install redis here
  #
  def should_host_redis?
    if is_zz?
      return app_config[:we_host_redis]
    end

    return @should_host_redis if @should_host_redis != nil
    if redis_host_name == this_host_name
      @should_host_redis = true
    else
      @should_host_redis = false
    end
  end

  # get the address of the host where
  # our redis isntance is - on single
  # deploy it will be us, on multi
  # it currently will live on the soon
  # to be useless db_master since we will
  # use Amazon RDS for db
  def redis_host_name
    if is_zz?
      return app_config[:redis_host]
    end

    return @redis_host_name if @redis_host_name != nil

    instances = ey['environment']['instances']
    # assume solo machine
    @redis_host_name = this_host_name

    # not solo so see if we are db_master which
    # is where we host redis
    instances.each do |instance|
      if instance['role'] == 'db_master'
        @redis_host_name = instance['private_hostname']
        break
      end
    end
    @redis_host_name
  end

  # return an array of all the app server machines
  # internal host names
  def all_app_servers
    if is_zz?
      return app_config[:app_servers]
    end

    return @all_app_servers if @all_app_servers != nil
    @app_server_types ||= Set.new [ 'solo', 'app', 'app_master' ].freeze

    instances = ey['environment']['instances']

    # collect all the app server hosts
    @all_app_servers = []
    instances.each do |instance|
      if @app_server_types.include?(instance['role'])
        @all_app_servers << instance['private_hostname']
      end
    end
    # add ourselves if we have no info, running on dev box
    @all_app_servers << this_host_name if @all_app_servers.empty?

    @all_app_servers
  end

  # return an array of all the server machines regardless of type
  def all_servers
    if is_zz?
      return app_config[:all_servers]
    end

    return @all_servers if @all_servers != nil

    instances = ey['environment']['instances']

    # collect all the app server hosts
    @all_servers = []
    instances.each do |instance|
      @all_servers << instance['private_hostname']
    end
    # add ourselves if we have no info, running on dev box
    @all_servers << this_host_name if @all_servers.empty?

    @all_servers
  end


  # determine if this instance should host
  # the resque cpu job instance
  #
  def should_host_resque_cpu?
    if is_zz?
      return app_config[:we_host_resque_cpu]
    end

    return @should_host_resque_cpu if @should_host_resque_cpu != nil
    if resque_cpu_host_names.include?(this_host_name)
      @should_host_resque_cpu = true
    else
      @should_host_resque_cpu = false
    end
  end

  # get the resque cpu bound jobs hosts
  def resque_cpu_host_names
    if is_zz?
      return app_config[:resque_cpus]
    end

    return @resque_cpu_host_names if @resque_cpu_host_names != nil

    instances = ey['environment']['instances']
    # assume solo machine
    @resque_cpu_host_names = []

    # not solo so see if we are util which
    # is where we host resquecpujobs
    instances.each do |instance|
      if instance['role'] == 'util' && instance['name'] =~ /^resquecpujobs/
        @resque_cpu_host_names << instance['private_hostname']
      end
    end
    if (@node['instance_role'] != 'solo')
      if @resque_cpu_host_names.length == 0
        # no resque cpu hosts found
      end
    else
      # solo machine so run here
      @resque_cpu_host_names << this_host_name
    end
    @resque_cpu_host_names
  end

  def this_instance_id
    if is_zz?
      return zz[:instance_id]
    end

    @this_instance_id ||= ey['this']
  end

  # get our own host address
  def this_host_name
    if is_zz?
      return zz[:local_hostname]
    end

    return @this_host_name if @this_host_name != nil

    instances = ey['environment']['instances']
    # assume localhost if can't find
    @this_host_name = 'localhost'

    this_id = this_instance_id
    instances.each do |instance|
      if instance['id'] == this_id
        @this_host_name = instance['private_hostname']
        break
      end
    end
    @this_host_name
  end
end