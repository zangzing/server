# this class is a helper for the Deploy Environment setup
class ZZDeployEnvironment
  def initialize(dna)
    if (dna.nil?)
      # build enough of the map to get local defaults
      dna = {'engineyard' => {'this' => 'local', 'environment' => {'instances' => []}}}
    end
    @dna = dna
  end

  def ey
    @ey ||= @dna['engineyard']
  end

  # determine if this instance should host
  # the redis server
  # true - yes we should install redis here
  #
  def should_host_redis?
    @should_host_redis if @should_host_redis != nil
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
    @redis_host_name if @redis_host_name != nil

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

  # determine if this instance should host
  # the resque cpu job instance
  #
  def should_host_resque_cpu?
    @should_host_resque_cpu if @should_host_resque_cpu != nil
    if resque_cpu_host_name == this_host_name
      @should_host_redis = true
    else
      @should_host_redis = false
    end
  end

  # get the resque cpu bound jobs host
  def resque_cpu_host_name
    @resque_cpu_host_name if @resque_cpu_host_name != nil

    instances = ey['environment']['instances']
    # assume solo machine
    @resque_cpu_host_name = this_host_name

    # not solo so see if we are db_master which
    # is where we host redis
    instances.each do |instance|
      if instance['role'] == 'util' && instance['name'] == 'resquecpujobs'
        @resque_cpu_host_name = instance['private_hostname']
        break
      end
    end
    @resque_cpu_host_name
  end

  def this_instance_id
    @this_instance_id ||= ey['this']
  end

  # get our own host address
  def this_host_name
    @this_host_name if @this_host_name != nil

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