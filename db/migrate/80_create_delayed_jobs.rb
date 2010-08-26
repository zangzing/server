class CreateDelayedJobs < ActiveRecord::Migration
  def self.up
    create_table    :cpu_bound_jobs, :guid => false, :force => true do |table|
     table.integer  :priority, :default => 0      # jobs can jump to the front of
     table.integer  :attempts, :default => 0      # retries, but still fail eventually
     table.text     :handler                      # YAML object dump
     table.text     :last_error                   # last failure
     table.datetime :run_at                       # schedule for later
     table.datetime :locked_at                    # set when client working this job
     table.datetime :failed_at                    # set when all retries have failed
     table.text     :locked_by                    # who is working on this object
     table.timestamps
    end
    create_table     :io_bound_jobs, :guid => false, :force => true do |table|
      table.integer  :priority, :default => 0      # jobs can jump to the front of
      table.integer  :attempts, :default => 0      # retries, but still fail eventually
      table.text     :handler                      # YAML object dump
      table.text     :last_error                   # last failure
      table.datetime :run_at                       # schedule for later
      table.datetime :locked_at                    # set when client working this job
      table.datetime :failed_at                    # set when all retries have failed
      table.text     :locked_by                    # who is working on this object
      table.timestamps
    end
  end

  def self.down
    drop_table :cpu_bound_jobs
    drop_table :io_bound_jobs
end
end
