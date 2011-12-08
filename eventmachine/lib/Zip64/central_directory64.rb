module Zip64

# 32 bit flavor of the central directory
class Zip64::CentralDirectory64 < CentralDirectory

  def extra64(entry)
    # create extra struct used for 64 bit numbers
    buf = []
    buf << 0x0001     # ID for 64 bit extra
    buf << 24         # header len
    Util.append64(buf, entry.size) # compressed size
    Util.append64(buf, entry.size) # uncompressed size
    Util.append64(buf, entry.local_offset) # offset to local header
    buf.pack('vvVVVVVV')
  end

  def central_directory(entry)
    buf = []
    buf << 0x02014b50           # signature
    buf << Util::ZIP64_VER      # made_by DOS
    buf << Util::ZIP64_VER      # version needed
    buf << entry.flags          # flags
    buf << 0                    # compression
    buf << entry.msdos_time     # time
    buf << entry.msdos_date     # date
    buf << entry.crc32          # crc32
    buf << Util::ZIP64_LEN      # compressed size
    buf << Util::ZIP64_LEN      # uncompressed size
    #buf << entry.size      # compressed size
    #buf << entry.size      # uncompressed size
    buf << entry.name.bytesize  # size of filename
    extra = extra64(entry)
    # now output the extra size
    buf << extra.bytesize

    buf << 0                    # file comment size
    buf << 0                    # disk #
    buf << 0                    # internal file attrs
    buf << 0                    # external file attrs
    buf << Util::ZIP64_LEN       # relative offset to associated local header
    buf.pack('VvvvvvvVVVvvvvvVV') + entry.name + extra
  end

  def z64_end_of_central_directory
    @z64_cd_offset = @mgr.offset
    header_size = 56            # fixed size of header
    buf = []
    buf << 0x06064b50           # signature
    Util.append64(buf, header_size - 12)   # record len of data after this field
    buf << Util::ZIP64_VER      # made_by DOS
    buf << Util::ZIP64_VER      # version needed
    buf << 0                    # disk number
    buf << 0                    # disk number with this cd
    Util.append64(buf, @mgr.entries.length)   # total entries this disk
    Util.append64(buf, @mgr.entries.length)   # total entries
    Util.append64(buf, @cd_size)             # size of cd
    Util.append64(buf, @cd_offset)           # offset of cd on this disk
    buf.pack('VVVvvVVVVVVVVVV')
  end

  def z64_end_of_central_directory_locator
    buf = []
    buf << 0x07064b50           # signature
    buf << 0                    # disk with 64 bit end of central dir
    Util.append64(buf, @z64_cd_offset)   # offset to 64 bit end of central dir
    buf << 1                    # total number of disks
    buf.pack('VVVVV')
  end

  # for zip64 we have some extra items to write
  # before end of central directory
  def write_end_of_central_directory
    @mgr.write_bytes(z64_end_of_central_directory)
    @mgr.write_bytes(z64_end_of_central_directory_locator)
    @mgr.write_bytes(end_of_central_directory)
  end


end

end
