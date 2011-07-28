class LineItemPhotoData < ActiveRecord::Base
  attr_accessible :source_url, :crop_instructions

  belongs_to :line_item


  
end
