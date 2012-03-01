class Admin::AdminScreensController < Admin::AdminController

  def index
    @stats = SystemStats.new.gather_stats   # the stats hash
    @status = @stats[:external_services]
    @page = 'status'
    @health_check = health_check(@stats[:health_check])
  end

private

  def health_check(hc)
    item = hc[:redis]
    status_msg = "<p>Redis connectivity check for: #{item[:server]} - #{HealthChecker.status_msg(item)}</p>"
    item = hc[:database]
    status_msg << "<p>Database connectivity check - #{HealthChecker.status_msg(item)}</p>"
    item = hc[:zza]
    status_msg << "<p>ZZA Server check - #{HealthChecker.status_msg(item)}</p>"
    item = hc[:app_servers]
    status_msg << "<p>App Servers: #{item[:servers].join(',')} - #{HealthChecker.status_msg(item)}</p>"

    if HealthChecker.all_ok(hc)
      msg = '<p><b style="font-size: 120%; color: green;">OK</b>' + status_msg+ '</p>'
    else
      msg = '<p><b style="font-size: 120%; color: red;">FAIL</b>' + status_msg+ '</p>'
    end

    return  msg
  end

end