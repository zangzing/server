# class that performs a system health check and
# returns a hash with the data
class HealthChecker

  def self.default_data(optional = {})
    hash = {}
    hash[:status] = 'Not Checked'
    hash[:msg] = ''
    hash[:took] = 0.0
    hash = hash.merge(optional)
  end

  def self.track(results, check_symbol, timeout, &block)
    curr = results[check_symbol]
    start_time = Time.now
    begin
      SystemTimer.timeout_after(timeout) do
        block.call
      end
      curr[:status] = 'OK'
    rescue Exception => ex
      curr[:status] = 'FAIL'
      curr[:msg] = ex.message
      msg = "Health check failed on #{curr_check}: " + ex.message
      z.track_event("health_check.fail", msg) rescue nil
      Rails.logger.error msg
      raise ex
    ensure
      end_time = Time.now
      curr[:took] = end_time.to_f - start_time.to_f
    end
  end

  def self.status_msg(item)
    msg = "#{item[:status]}"
    msg << " - #{item[:msg]}" unless item[:msg].blank?
    msg << format(" - took %.3f", item[:took])
  end

  # returns true if all of them are ok, false if any failed
  def self.all_ok(hc)
    hc.each do |key, value|
      return false if value[:status] != 'OK'
    end
    return true
  end

  # perform a health check and return the result data as a service key
  # followed by data about that service.
  #
  # {
  #   :app_servers => {
  #     :status => 'Not Checked' : 'OK' : 'FAIL'
  #     :msg => extra string message
  #     :took => time in float seconds that check took
  #     :servers => [app_server,...]  array of app server strings
  #     :rails_env => the rails environment
  #   }
  #   :redis => {
  #     :status => 'Not Checked' : 'OK' : 'FAIL'
  #     :msg => extra string message
  #     :took => time in float seconds that check took
  #     :server => the redis server string
  #   }
  #   :database => {
  #     :status => 'Not Checked' : 'OK' : 'FAIL'
  #     :msg => extra string message
  #     :took => time in float seconds that check took
  #   }
  #   :zza => {
  #     :status => 'Not Checked' : 'OK' : 'FAIL'
  #     :msg => extra string message
  #     :took => time in float seconds that check took
  #   }
  # }
  #
  def self.health_check
    max_total_time = 25.seconds
    max_time_per_check = 15.seconds
    z = ZZ::ZZA.new
    results = {
        :app_servers => default_data({:status => 'OK', :servers => Server::Application.config.deploy_environment.all_app_servers, :rails_env => Rails.env}),
        :redis => default_data({:server => Resque.redis_id}),
        :database => default_data(),
        :zza => default_data(),
    }

    begin
      # wrap the calls with a timeout check so we don't
      # end up potentially hanging here - we wrap the entire
      # set and then each individual test
      SystemTimer.timeout_after(max_total_time) do

        track(results, :redis, max_time_per_check) do
          # just your basic ping check
          redis = Resque.redis
          redis.ping
        end

        track(results, :database, max_time_per_check) do
          # build a query that hits the database but does not return any actual data
          # to minimize performance impact
          Photo.first(:conditions => ["TRUE = FALSE"])
        end

        track(results, :zza, max_time_per_check) do
          if ZZ::ZZA.unreachable? then
            raise "ZZA server is not reachable."
          end
        end
      end

    rescue Exception => ex
      # track already logged the error
    end

    results
  end
end