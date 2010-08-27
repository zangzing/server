  require File.dirname(__FILE__) + '/../config/environment'

  Delayed::IoBoundWorker.new.start  