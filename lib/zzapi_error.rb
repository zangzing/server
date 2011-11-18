# this class tracks any zz api error condition set
class ZZAPIError
  attr_reader :err_set, :message, :code

  def self.initialize
    @err_set = false
  end

  def set(message, code)
    @err_set = true
    @message = message  # can be string or array of strings, or a hash
    @code = code
  end
end