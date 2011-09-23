class ImageCrop
  attr_accessor :top, :left, :bottom, :right

  def initialize(top, left, bottom, right)
    self.top = top
    self.left = left
    self.right = right
    self.bottom = bottom
  end

  # build a crop object from json passed to us
  def self.from_json(json_str)
    return nil if json_str.nil?

    c = JSON.parse(json_str)
    crop = ImageCrop.new(c['top'], c['left'], c['bottom'], c['right'])
  end

  # build the imagemagick convert command given the
  # pixel dimensions of the whole we return the
  # command that contrains to our crop values converted
  # to pixel coords
  def crop_str(width, height)
    pix_top = Float(self.top * height)
    pix_left = Float(self.left * width)
    pix_bottom = Float(self.bottom * height)
    pix_right = Float(self.right * width)
    pix_width = pix_right - pix_left
    pix_height = pix_bottom - pix_top
    "-crop #{pix_width.round}x#{pix_height.round}+#{pix_left.round}+#{pix_top.round}"
  end

  def as_hash
    hash = { :top => top, :left => left, :bottom => bottom, :right => right }
  end

  # fast conversion to json
  def to_json
    JSON.fast_generate(as_hash)
  end
end
