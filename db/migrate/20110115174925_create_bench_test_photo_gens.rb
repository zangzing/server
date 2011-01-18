class CreateBenchTestPhotoGens < ActiveRecord::Migration
  def self.up
    create_table :bench_test_photo_gens do |t|
      t.string :result_message
      t.datetime :start
      t.datetime :stop
      t.integer :iterations
      t.integer :file_size
      t.string :album_id
      t.string :user_id
      t.integer :error_count
      t.integer :good_count

      t.timestamps
    end
  end

  def self.down
    drop_table :bench_test_photo_gens
  end
end
