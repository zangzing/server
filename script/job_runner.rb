  require File.dirname(__FILE__) + '/../config/environment'

  Delayed::Worker.new.start  