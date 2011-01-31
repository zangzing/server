module ZZ
  class CommandLineException < StandardError
  end

  class CommandLineNotFound < CommandLineException
  end
end