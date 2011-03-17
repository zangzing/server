class CreateBulkIdGenerators < ActiveRecord::Migration
  def self.up
    create_table :bulk_id_generators, :force => true do |t|
      t.string                 :table_name,       :null => false
      t.column                 :next_start_id, :bigint, :null => false
      t.integer                :batch_size,       :null => false
      t.integer                :lock_version,     :default => 0
    end
    add_index :bulk_id_generators, :table_name, :unique => true


    # seed the initial values
    BulkIdGenerator.create(:table_name => 'photos',
                            :next_start_id => 169911073720,
                            :batch_size => 1000,
                            :lock_version => 0)

    # no longer an auto increment field since we manage directly
    change_column :photos, :id, :bigint, :null => false
  end

  def self.down
    drop_table :bulk_id_generators
  end
end
