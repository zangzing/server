class BenchTest::ResqueNoOp < ActiveRecord::Base
  validates :iterations, :presence => true
end
