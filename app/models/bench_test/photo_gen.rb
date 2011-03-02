class BenchTest::PhotoGen < ActiveRecord::Base
  validates :iterations, :presence => true
end
