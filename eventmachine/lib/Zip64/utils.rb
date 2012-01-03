# module level utils
module Zip64

class Util
  unless defined?(ZIP64_LEN)
    ZIP64_LEN = 0xffffffff
    ZIP64_WORDLEN = 0xffff
    ZIP64_VER = 45
    ZIP32_VER = 20
  end
  # convert to msdos time format
  def self.msdos_time(time)
    mt = 0
    mt |= time.sec
    mt |= time.min << 5
    mt |= time.hour << 11
    mt
  end

  # convert to msdos date format
  def self.msdos_date(date)
    md = 0
    md |= date.day
    md |= date.month << 5
    md |= (date.year - 1980) << 9
    md
  end

  # determine if we should use actual size or
  # return the 64 bit constant for use in 32 bit fields
  def self.size32(val, use_64bit)
    use_64bit ? ZIP_LEN64 : val
  end

  # do a 64 bit append in little endian order so
  # we can pack with 'V' since there is no support
  # for packing 64 bit numbers with proper byte order
  def self.append64(arr, val)
    arr << (val & 0xffffffff)
    arr << (val >> 32)
  end
end

end
