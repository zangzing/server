require "rspec"
require "image_crop"

describe "ImageCrop" do

    it "should create a proper crop command" do
      crop = ImageCrop.new(0.087, 0.513, 0.56, 0.75)
      crop_str = crop.crop_str(2500, 1667)
      crop_str.should == '-crop 593x788+1283+145'

      crop = ImageCrop.new(0, 0, 1, 1)
      crop_str = crop.crop_str(2500, 1667)
      crop_str.should == '-crop 2500x1667+0+0'
    end

end