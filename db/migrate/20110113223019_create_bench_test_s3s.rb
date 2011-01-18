class CreateBenchTestS3s < ActiveRecord::Migration
  def self.up
    create_table :bench_test_s3s do |t|
      t.string :result_message
      t.datetime :start
      t.datetime :stop
      t.integer :iterations
      t.integer :file_size
      t.boolean :upload

      t.timestamps
    end
  end

  def self.down
    drop_table :bench_test_s3s
  end
end
