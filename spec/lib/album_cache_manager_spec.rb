require "rspec"
require "mysql2"
require "config/initializers/zangzing_config"
require "config/application"
require 'benchmark'
require 'system_timer'

class CacheDB
  ALBUMS_I_LIKE = 1

  def self.initialize
    db_config = DatabaseConfig.config.dup
    db_config[:database]= "server_development"
    ActiveRecord::Base.establish_connection(db_config)

    db_config[:database] = db_config[:cache_database]

    @@db = Mysql2::Client.new(db_config)
    @@db.query_options.merge!(:symbolize_keys => true)

    result = db.query("show variables like 'max_allowed_packet'")
    @@safe_max_size = result.first[:Value].to_i - (16 * 1024)
  end

  def self.db
    @@db
  end

  def self.safe_max_size
    @@safe_max_size
  end
end

CacheDB.initialize

class Track < ActiveRecord::Base
end

describe "Cache manager Test" do

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
        type = CacheDB::ALBUMS_I_LIKE
        user_last_touch_at = Time.now.to_i
        base_cmd = "INSERT INTO tracks(user_id, tracked_id, track_type, user_last_touch_at) VALUES "
        end_cmd = " ON DUPLICATE KEY UPDATE user_last_touch_at = VALUES(user_last_touch_at)"
        cmd = base_cmd.dup
        rows = 5000
        cur_rows = 0
        (1..rows).each do |i|
          cmd << "," if cur_rows > 0
          cur_rows += 1
          cmd << "(#{user_id}, #{album_id}, #{type}, #{user_last_touch_at})"
          if cmd.length > CacheDB.safe_max_size
            # getting close to the limit so execute this one now
            cmd << end_cmd
            result = db.query(cmd)
            cmd = base_cmd.dup
            cur_rows = 0
          end
          album_id += 1
        end
        if cur_rows > 0
          cmd << end_cmd
          result = db.query(cmd)
        end
      end
    end

    cnt = 0
    Benchmark.bm(25) do |x|
      x.report('select') do
        1.times do |i|
          cmd = "SELECT user_id, tracked_id, track_type FROM tracks " +
                 "WHERE user_id IS NOT NULL"
          results = db.query(cmd)
          results.each do |result|
            u = result[:user_id]
            a = result[:tracked_id]
            t = result[:track_type]
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
        type = CacheDB::ALBUMS_I_LIKE
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

