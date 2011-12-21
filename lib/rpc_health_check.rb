require 'zz'

# this class wraps a basic set of health check calls
# currently this is just an echo that goes to all front ends
class RPCHealthCheck
  # do a deploy against all web server front ends
  # using the git tag specified
  def self.echo(value)
    rpc_responses = ZZ::Async::RemoteJobWorker.remote_rpc_app_servers(self.name, 'echo_handler', :value => value)
    # got the responses, lets see if we have an error on any of them and build an exception if we do
    RPCResponse.exception_on_error(rpc_responses)

    # verify they all sent back what we sent to them
    rpc_responses.each do |rpc_response|
      response = rpc_response.response
      result = response[:result]
      raise "Echo data did not match, sent: #{value}, got back: #{result}" unless result == value
    end

    return true
  end

  def self.stress(attempts)
    attempts.times do |attempt|
      puts "Echo call #{attempt}"
      echo_result = echo('test_data')
      puts "Echo call #{attempt} returned: #{echo_result}"
    end
  end

  # simply echos back the value passed
  def self.echo_handler(params)
    value = params[:value]

    # echo back the value
    { :result => value }
  end

end