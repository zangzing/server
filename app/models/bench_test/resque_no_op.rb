class BenchTest::ResqueNoOp < ActiveRecord::Base
  usesguid
  validates :iterations, :presence => true
end
