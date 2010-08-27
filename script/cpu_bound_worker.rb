  require File.dirname(__FILE__) + '/../config/environment'

  Delayed::CpuBoundWorker.new.start  