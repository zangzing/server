class BenchTest::S3 < ActiveRecord::Base
  usesguid
  validates :iterations, :presence => true
  validates :file_size, :presence => true
  validates :upload, :presence => true
end
