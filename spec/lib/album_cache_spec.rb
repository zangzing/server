require "rspec"
require "config/initializers/zangzing_config"
require "cache/album/manager"
#require "config/application"
require 'benchmark'
require 'system_timer'

describe "Cache manager Test" do

  cm = Cache::Album::Manager.new()

  it "should get an instance" do
    cm.should_not == nil
  end

  sm = Cache::Album::Manager.make_shared
  it "should get an instance" do
    sm.should_not == nil
  end

  it "should be fast" do

    ts = Set.new
    30000.times do |i|
      ts.add([1,i+30000])
    end
    Benchmark.bm(25) do |x|
      x.report('inserts') do
        100000.times do |i|
          ts.add([1,i])
        end
        a = ts.to_a
      end
    end

    puts "Set size is #{ts.length}"

  end


end

