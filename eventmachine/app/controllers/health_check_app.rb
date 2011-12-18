class HealthCheckApp < AppBase

  def health_check(env)
    header = {
        'Content-Type' => 'text/plain',
        'Cache-Control' => 'no-cache',
    }

    body = "MONIT-WE-ARE-HEALTHY\n\n"
    body << "OK\n\n"
    body << "Connection count: #{EventMachine::connection_count}\n"

    [200, header, [body]]
  end

end

