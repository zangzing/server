require 'spec_helper'
require 'benchmark'

describe EZPrints::ShippingCalculator do

  describe "Calculator validation" do

    before(:each) do
    end

    it 'should benchmarks the EZPrints shipping calculator API' do
      #todo create the objects needed for an order. Currently
      # as a shortcut just doing this with an existing object since
      # we want to benchmark the EZPrints shipping API to see if it is fast enough
      calc = EZPrints::ShippingCalculator.new
      order = Order.find(5)
      Benchmark.bm(25) do |x|
        x.report('EZPrints ShipCalc') do
          1.times do
            calc.shipping_costs(order)
          end
        end
      end
    end

    it 'should send an order to EZPrints and get shipping info' do
    end

  end
end
