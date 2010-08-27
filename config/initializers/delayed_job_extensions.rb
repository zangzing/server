require 'delayed_job'
require 'delayed/backend/active_record'
require 'cpu_bound_job'
require 'cpu_bound_worker'
require 'io_bound_job'
require 'io_bound_worker'

Delayed::IoBoundWorker.backend = :active_record
Delayed::CpuBoundWorker.backend = :active_record
