module Zip64

# represents context for a single file
# this is the 64 bit flavor
class WriteEntry64 < WriteEntry

  def extra64
    # create extra struct used for 64 bit numbers
    buf = []
    buf << 0x0001     # ID for 64 bit extra
    buf << 16         # header len
    Util.append64(buf, @size) # compressed size
    Util.append64(buf, @size) # uncompressed size
    buf.pack('vvVVVV')
  end

  def local_header
    buf = []
    buf << 0x04034b50     # sig
    buf << Util::ZIP64_VER              # version to extract
    @flags = ((1<<11) | (needs_crc32_calc ? (1 << 3) : 0))      # (UTF-8, and if needs crc calc, will add in data descriptor)
    buf << @flags         # general purpose flag (UTF-8, and if needs crc calc, will add in data descriptor)
    buf << 0              # compression (none)
    buf << @msdos_time    # time
    buf << @msdos_date    # date
    buf << @crc32         # crc
    buf << Util::ZIP64_LEN     # compressed size
    buf << Util::ZIP64_LEN     # uncompressed size
    #buf << @size     # compressed size
    #buf << @size     # uncompressed size
    buf << @name.bytesize # size of filename
    # now output the extra size
    extra = extra64
#    extra = ''
    buf << extra.bytesize
    # ok, turn it into a packed string of bytes
    buf.pack('VvvvvvVVVvv') + @name + extra
  end

  # returns the data descriptor raw string
  # which holds the crc32 and compressed, uncompressed sizes
  def data_descriptor
    buf = []
    buf << 0x08074b50         # signature
    buf << @crc32             # crc
    Util.append64(buf, @size) # compressed size
    Util.append64(buf, @size) # uncompressed size
    # pack for 64 bit size fields
    buf.pack('VVVVVV')
  end

end

end  # Zip64 module
