require '../test_helper'
require 'benchmark'
require 'stringio'

Benchmark.bm(20) do |x|
  hash = {:url => 'http://www.google.com', :name=>'this is a name'}
  array = []

  1000.times do
    array << hash
  end



  x.report('to_json') do
    100.times do
      array.to_json
    end
  end


  x.report('JSON.generate') do
    100.times do
      JSON.generate array
    end
  end

  x.report('JSON.fast_generate') do
    100.times do
      JSON.fast_generate array
    end
  end

  x.report('ActiveSupport::JSON.encode(object)') do
    100.times do
      ActiveSupport::JSON.encode array
    end
  end


  x.report('manual') do
    100.times do
      array.map{|p| '{'+ [:url, :name].map{|attr| "#{attr}:\"#{p[attr]}\"" }.join(', ') +'}'}.join(",")
    end
  end
end






