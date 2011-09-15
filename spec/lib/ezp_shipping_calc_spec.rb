require 'spec_helper'
require 'benchmark'

describe EZPrints::EZPManager do

  before(:each) do
  end

  it 'should benchmarks the EZPrints shipping calculator API' do
    #todo create the objects needed for an order. Currently
    # as a shortcut just doing this with an existing object since
    # we want to benchmark the EZPrints shipping API to see if it is fast enough
    calc = EZPrints::EZPManager.new
    order = Order.find(5)
    Benchmark.bm(25) do |x|
      x.report('EZPrints ShipCalc') do
        1.times do
          prices = calc.shipping_costs(order)
          prices[:type].should == 'FC'
          prices[:price].should == 1.75
        end
      end
    end
  end

  it 'should send an order to EZPrints' do
    ezp = EZPrints::EZPManager.new
    order = Order.find(5)
    result_xml = ezp.submit_order(order)
    #todo dig out result
  end

end
