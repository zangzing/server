class BenchTest::S3 < ActiveRecord::Base
  validates :iterations, :presence => true
  validates :file_size, :presence => true
end
