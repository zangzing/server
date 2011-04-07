class TransactionIdGenerator < ActiveRecord::Migration
  def self.up
    # seed the initial values
    # not really a table just uses the bulk id generator for
    # unique within the database values
    BulkIdGenerator.create(:table_name => 'cache_tx_generator',
                            :next_start_id => 1,
                            :batch_size => 1000,
                            :lock_version => 0)

  end

  def self.down
  end
end
