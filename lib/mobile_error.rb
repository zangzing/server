# this class tracks any mobile api error condition set
class MobileError
  attr_reader :err_set, :message, :code

  def self.initialize
    @err_set = false
  end

  def set(message, code)
    @err_set = true
    @message = message  # can be string or array of strings
    @code = code
  end
end