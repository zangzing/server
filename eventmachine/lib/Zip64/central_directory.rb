module Zip64

# 32 bit flavor of the central directory
class Zip64::CentralDirectory

  def initialize(mgr)
    @mgr = mgr
  end

  def central_directory(entry)
    buf = []
    buf << 0x02014b50           # signature
    buf << Util::ZIP32_VER      # our version made by
    buf << Util::ZIP32_VER      # version to extract
    buf << entry.flags          # flags
    buf << 0                    # compression
    buf << entry.msdos_time     # time
    buf << entry.msdos_date     # date
    buf << entry.crc32          # crc32
    buf << entry.size           # compressed size
    buf << entry.size           # uncompressed size
    buf << entry.name.bytesize  # size of filename
    buf << 0                    # extra size
    buf << 0                    # file comment size
    buf << 0                    # disk #
    buf << 0                    # internal file attrs
    buf << 0                    # external file attrs
    buf << entry.local_offset   # relative offset to associated local header
    buf.pack('VvvvvvvVVVvvvvvVV') + entry.name
  end

  def end_of_central_directory
    buf = []
    buf << 0x06054b50           # signature
    buf << 0                    # disk #
    buf << 0                    # disk # with central dir
    buf << @mgr.entries.length  # total entries in local central dir
    buf << @mgr.entries.length  # total entries in all central dir
    buf << @cd_size             # central directory size
    buf << @cd_offset           # offset to central dir
    buf << 0                    # file comment
    buf.pack('VvvvvVVv')
  end

  def write_end_of_central_directory
    @mgr.write_bytes(end_of_central_directory)
  end

  # given the write_entries build and output
  # the central directory related stuff
  def write_central_directory
    @cd_offset = @mgr.offset
    @mgr.entries.each do |entry|
      @mgr.write_bytes(central_directory(entry))
    end
    @cd_size = @mgr.offset - @cd_offset
    write_end_of_central_directory
  end

end

end