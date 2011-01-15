require 'benchmark'
require 'stringio'

Benchmark.bm(20) do |x|
  x.report('<<') do
    1_000_000.times do
      one = 'one'
      two = 'two'
      three = 'three'
      y = one << two << three
    end
  end
  x.report('+') do
    1_000_000.times do
      one = 'one'
      two = 'two'
      three = 'three'
      y = one + two + three
    end
  end
  x.report('#{one}#{two}#{three}') do
    1_000_000.times do
      one = 'one'
      two = 'two'
      three = 'three'
      y = "#{one}#{two}#{three}"
    end
  end
#  x.report('one#{two}#{three}') do
#    1_000_000.times do
#      two = 'two'
#      three = 'three'
#      y = "one#{two}#{three}"
#    end
#  end
#  x.report('onetwo#{three}') do
#    1_000_000.times do
#      three = 'three'
#      y = "onetwo#{three}"
#    end
#  end

  x.report('array join') do
    1_000_000.times do
      a = Array.new
      a << 'one'
      a << 'two'
      a << 'three'
      a.join(",")
    end
  end

  x.report('string io') do
    1_000_000.times do
      s = StringIO.new
      s.write 'one'
      s.write 'two'
      s.write 'three'
      s.string
    end

  end
end