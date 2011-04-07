require "rspec"
require "mysql2"
require "config/initializers/zangzing_config"
require "config/application"
require 'benchmark'
require 'system_timer'

class CacheDB
  attr_accessor :db_conn

  def self.initialize
    db_config = DatabaseConfig.config.dup
    ActiveRecord::Base.establish_connection(db_config)

    cache_db_config = CacheDatabaseConfig.config.dup
    @@db = ActiveRecord::Base.mysql2_connection(cache_db_config)

    result = db.execute("show variables like 'max_allowed_packet'")
    @@safe_max_size = result.first[1].to_i - (16 * 1024)
  end

  def self.db
    @@db
  end

  def self.safe_max_size
    @@safe_max_size
  end

  def self.fast_insert(base_cmd, end_cmd, rows)
    cmd = base_cmd.dup
    cur_rows = 0
    rows.each do |values|
      cmd << "," if cur_rows > 0
      cur_rows += 1
      vcmd = '('
      first = true
      values.each do |v|
        vcmd << ',' unless first
        first = false
        vcmd << v.to_s
      end
      vcmd << ')'
      cmd << vcmd
      if cmd.length > CacheDB.safe_max_size
        # getting close to the limit so execute this one now
        cmd << end_cmd
        result = db.execute(cmd)
        cmd = base_cmd.dup
        cur_rows = 0
      end
    end
    if cur_rows > 0
      cmd << end_cmd
      result = db.execute(cmd)
    end
  end
end

CacheDB.initialize

class Track < ActiveRecord::Base
end

describe "Low level DB performance Test" do

  db = CacheDB.db

  it "should get a db connection" do
    db.should_not == nil
  end

  it "should be fast" do

#    db.query("DELETE FROM tracked")

    user_id = rand(999999)

    Benchmark.bm(25) do |x|
      x.report('inserts') do
        album_id = 1
        type = 1
        user_last_touch_at = Time.now.to_i
        rows = []
        (1..20000).each do |i|
          row = [user_id, album_id, type, user_last_touch_at]
          rows << row
          album_id += 1
        end
        base_cmd = "INSERT INTO c_tracks(user_id, tracked_id, track_type, user_last_touch_at) VALUES "
        end_cmd = " ON DUPLICATE KEY UPDATE user_last_touch_at = VALUES(user_last_touch_at)"
        CacheDB.fast_insert(base_cmd, end_cmd, rows)
      end
    end

    cnt = 0
    Benchmark.bm(25) do |x|
      x.report('select') do
        1.times do |i|
          cmd = "SELECT user_id, tracked_id, track_type FROM c_tracks "
                 #"WHERE user_id IS NOT NULL"
          results = db.execute(cmd)
          results.each do |result|
            u = result[0]
            a = result[1]
            t = result[2]
#           u = result[:user_id]
#            a = result[:tracked_id]
#            t = result[:track_type]
            cnt += 1
          end
        end
      end
    end

    puts "row count = #{cnt}"

#    Benchmark.bm(25) do |x|
#      x.report('delete') do
#        1.times do |i|
#          cmd = "DELETE FROM tracked WHERE user_id = #{user_id}"
#          result = db.query(cmd)
#        end
#      end
#    end


    Benchmark.bm(25) do |x|
      x.report('AR inserts') do
        album_id = 1
        type = 1
        user_last_touch_at = Time.now.to_i
        1000.times do |i|
          album_id += 1
          f = Track.new
          f.track_type = type
          f.user_id = user_id
          f.tracked_id = album_id
          f.save
        end
      end
    end

    cnt = 0
    Benchmark.bm(25) do |x|
      x.report('AR select') do
        1.times do |i|
          results = Track.all
          results.each do |result|
            u = result.user_id
            a = result.tracked_id
            t = result.track_type
            cnt += 1
          end
        end
      end
    end

    puts "AR row count = #{cnt}"


  end


end

