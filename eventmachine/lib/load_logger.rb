require 'logger'

def load_logger
  cfg = AsyncConfig.config

  log_type = cfg[:log_type]
  case log_type
    when 'stdout'
      logger = Logger.new(STDOUT)
    when 'file'
      logger = Logger.new(cfg[:log_path])
    when 'syslog'
      logger = Syslogger.new(cfg[:log_app_name])
    else
      logger = Logger.new(STDOUT)
  end

  logger.level = case cfg[:log_level]
     when 'DEBUG'
        Logger::DEBUG
     when 'INFO'
        Logger::INFO
     when 'WARN'
        Logger::WARN
     when 'ERROR'
        Logger::ERROR
     when 'FATAL'
        Logger::FATAL
     else
        Logger::UNKNOWN
  end
  logger
end

# only close the logger if it is a file
def close_logger(logger)
  cfg = AsyncConfig.config

  log_type = cfg[:log_type]
  case log_type
    when 'file'
      logger.close rescue nil
  end
end

