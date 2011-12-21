module Zip64

# represents context for a single file
class WriteEntry
  attr_reader   :needs_crc32_calc, :local_offset, :size, :crc32, :flags, :msdos_date, :msdos_time, :name

  def initialize(mgr, local_offset, name, size, crc32, date)
    @needs_crc32_calc = crc32.nil?
    @crc32 = crc32 || 0
    @mgr = mgr
    @name = name
    @date = date
    @size = size
    @msdos_date = Util.msdos_date(date)
    @msdos_time = Util.msdos_time(date)
    @local_offset = local_offset
    @flags = 0
  end

  def calc_crc32(chunk)
    if needs_crc32_calc
      @crc32 = Zlib.crc32(chunk, @crc32)
    end
  end

  def write_bytes(chunk)
    @mgr.write_bytes(chunk)
  end

  def local_header
    buf = []
    buf << 0x04034b50     # sig
    buf << Util::ZIP32_VER  # version to extract
    @flags = ((1<<11) | (needs_crc32_calc ? (1 << 3) : 0))      # (UTF-8, and if needs crc calc, will add in data descriptor)
    buf << @flags         # general purpose flag (UTF-8, and if needs crc calc, will add in data descriptor)
    buf << 0              # compression (none)
    buf << @msdos_time    # time
    buf << @msdos_date    # date
    buf << @crc32         # crc
    if needs_crc32_calc
      buf << 0            # compressed size
      buf << 0            # uncompressed size
    else
      buf << @size        # compressed size
      buf << @size        # uncompressed size
    end
    buf << @name.bytesize # size of filename
    buf << 0              # extra size
    # ok, turn it into a packed string of bytes
    buf.pack('VvvvvvVVVvv') + @name
  end

  # write our local header into the output stream
  def write_local_header
    write_bytes(local_header)
  end

  # returns the data descriptor raw string
  # which holds the crc32 and compressed, uncompressed sizes
  # this gets used in cases where we did not initially have
  # the crc32
  def data_descriptor
    buf = []
    buf << 0x08074b50         # signature
    buf << @crc32             # crc
    buf << @size              # compressed size
    buf << @size              # uncompressed size
    buf.pack('VVVV')
  end

  # write any trailing bytes (i.e. data descriptor if needed
  def write_trailer
    if needs_crc32_calc
      write_bytes(data_descriptor)
    end
  end
end

end  # Zip64 module