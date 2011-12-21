require 'zlib'

# return a small back trace limited to
# limit specified or 5 lines by default
# also adds exception message at top
def small_back_trace(ex, lines = 5)
  result = ex.message + "\n"
  bt = ex.backtrace
  lines_left = lines
  bt.each do |line|
    if (lines_left > 0)
      result << line + "\n"
    end
    lines_left -= 1
  end

  return result
end

# return a safe default if nil
def safe_default(item, default)
  item.nil? ? default : item
end

# return the default if the map does not exist, or the
# map[key] element does not exist
def safe_hash_default(map, key, default)
  value = map.nil? ? default : map[key]
  safe_default(value, default)
end

# limit the max number for a valid date of a photo
# technically it looks like rails has a bug on 32 bit systems
# where it is not dealing with Time values passed into it that
# hold times beyond the max unix epoch even though the
# field type is datetime in the database that should
# support up to year 9999
def max_safe_epoch_time epoch_time
  epoch_time > 2147483647 ? 2147483647 : epoch_time
end

# gzip compressor and sanity checker
# does a checked compress and returns the result
def checked_gzip_compress(orig, zza_event, context)
  # since we have seen issues with corrupt cache
  # data we are trying to eliminate gzip as the source
  # of the problem so checksum, compress, uncompress and check
  #
  crc = Zlib.crc32(orig, 0)
  # try to get it right up to 5 times before giving up
  3.times do |i|
    compressed = ActiveSupport::Gzip.compress(orig)
    decompressed = ActiveSupport::Gzip.decompress(compressed)
    crc_after = Zlib.crc32(decompressed, 0)
    return compressed if crc == crc_after  # all good

    # crc did not match
    Rails.logger.error("Bad compressed data CRC32 checksum did not match called from: #{context}")
    ZZ::ZZA.new.track_event(zza_event, {:context => context})
  end

  # if we get here we didn't succeed even after multiple tries
  raise "Bad compressed data CRC32 checksum did not match after multiple tries: #{context}"
end
