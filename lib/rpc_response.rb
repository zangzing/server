# this class holds the results of an RPC call
class RPCResponse
  attr_accessor :error_code, :error_message, :server_name, :response, :async_id

  def initialize(server_name, async_id)
    self.server_name = server_name
    self.async_id = async_id
    self.error_code = -1  # not complete
    self.error_message = "Did not complete"
  end

  def complete?
    return self.error_code == -1 ? false : true
  end

  # generate an exception if any of the responses have an error
  def self.exception_on_error(responses)
    msg = ""
    got_err = false
    responses.each do |response|
      if response.error_code != 0
        # got an error, flag it and add to message
        got_err = true
        msg << "RPC Failed for #{response.server_name} with #{response.error_message}\n"
      end
    end
    raise RPCResponseException.new(msg) if got_err
  end
end