namespace :jobs do
  desc "Clear the CpuBound delayed_job queue."
  task :cpubound_clear => :environment do
    Delayed::CpuBoundJob.delete_all
  end

  desc "Start a CpuBound delayed_job worker."
  task :cpubound_work => :environment do
    Delayed::CpuBoundWorker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
  end


  desc "Clear the IoBound delayed_job queue."
  task :iobound_clear => :environment do
    Delayed::IoBoundJob.delete_all
  end

  desc "Start a IoBound delayed_job worker."
  task :iobound_work => :environment do
    Delayed::IoBoundWorker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
  end


end