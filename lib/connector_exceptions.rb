class InvalidToken < StandardError
  def message
    'Invalid authentication token'
  end
end

class HttpCallFail < StandardError
  def message
    'Remote service call failed'
  end
end

class InvalidCredentials < StandardError
  def message
    'Invalid username or password. Please try again.'
  end
end
