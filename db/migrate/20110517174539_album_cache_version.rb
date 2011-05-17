class AlbumCacheVersion < ActiveRecord::Migration
  def self.up
    add_column :albums, :cache_version, :bigint, :default => 0

    # seed the id generator, we use this because
    # it is a handy mechanism to create unique ids
    # across app servers
    BulkIdGenerator.create(:table_name => 'album_cache_version',
                            :next_start_id => 1,
                            :batch_size => 1000,
                            :lock_version => 0)

  end

  def self.down
    remove_column :albums, :cache_version
  end
end
