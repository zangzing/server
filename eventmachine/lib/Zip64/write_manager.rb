require 'digest/sha1'

module Zip64
# manages a collection of zip files from a stream added on the fly
# as we go and injects the data into an output stream with the appropriate
# zip structures wrapping the raw data.  When told to finish up it writes
# the central directory with the data it has been building on the fly
# and outputs that to the stream
#
# The zip64 protocol is defined in:
# http://www.pkware.com/documents/casestudies/APPNOTE.TXT
#
class WriteManager
  attr_reader :use_64bit, :offset, :entries, :seek_to, :entry
  unless defined?(SIZE_4GB)
    SIZE_1MB = 1024 * 1024
    SIZE_Z32_LIMIT = SIZE_1MB * 1024 * 4  # 4GB
    SIZE_Z32_PADDING = SIZE_1MB * 128
    SEEK_ONLY = SIZE_Z32_LIMIT * SIZE_Z32_LIMIT
  end

  # a stream that does nothing,
  # used when we are just counting
  class BitBucket
    def write(chunk)
    end

    def close
    end
  end

  # pass in the out_stream to use and the expected size
  # we use the expected size to determine if we are
  # going to use 64 bit mode
  # the seek_to value tells us the location we
  # should seek to before we begin to output data
  # this can be used for byte range mode but only if
  # have known sizes and crc32 for each url which can
  # be used in the central directory
  def initialize(out_stream, expected_size = nil, seek_to = 0)
    @out_stream = out_stream
    @entry = nil
    @entries = []
    # use 64bit if we might go over 4GB or size is unknown
    @use_64bit = expected_size.nil? || (expected_size + SIZE_Z32_PADDING >= SIZE_Z32_LIMIT)
    @offset = 0
    @seek_to = seek_to
    @central_directory = use_64bit ? CentralDirectory64.new(self) : CentralDirectory.new(self)
  end

  def clean_up
    @out_stream = nil
    @central_directory = nil
    @entries = nil
  end

  # used when we are in seek mode
  # to simply skip data without having to
  # specify a chunk
  def add_empty_bytes(count)
    @offset += count
  end

  # returns true if we need actual data
  # because we are at or will be past the
  # seek to point - tells us if we need
  # to fetch real incoming data or can just
  # skip this one
  # if bytes_to_use is > 0 we need real data
  def bytes_to_use(file_size)
    bytes_before_seek = @seek_to - @offset
    if bytes_before_seek >= 0
      bytes_needed = file_size - bytes_before_seek
    else
      bytes_needed = file_size
    end
    # if > 0 we need real bytes
    bytes_needed
  end

  # true if we need to provide real bytes, false
  # if we don't need them because they are before
  # the seek_to position
  def need_real_bytes?(file_size)
    bytes_to_use(file_size) > 0
  end

  # write the bytes but observe our current position relative
  # to where we should seek to, if we are past the seek point
  # we can write full sets of data, if we are before it we need
  # to see if part of the data should be written
  def write_bytes(chunk)
    count = chunk.bytesize
    bytes_needed = bytes_to_use(count)
    if bytes_needed == count
      # write full amount
      @out_stream.write(chunk)
    else
      # see if we are in the range of needed bytes
      # otherwise just skip the bytes
      if bytes_needed > 0
        first = count - bytes_needed
        last = count - 1
        chunk = chunk[first..last]
        # write only the bytes after the seek point
        @out_stream.write(chunk)
      end
    end
    # move offset by full size of chunk since we consumed that many bytes
    @offset += count
  end

  # this method will create a WriteManager
  # in calculate size mode without outputing
  # the data for the stream but just to calculate
  # the total size of the zip which is needed
  # for the http content-length header sent
  # back to the client
  #
  # returns an array of
  # zip_file_size - the total zip file size nil if cannot determine due to 1 or more missing file sizes
  # data_size - the size of just the data if known
  # sha1_hash - the unique hash for the given set of files using the file name, url, size, and crc32 as inputs
  # supports_seek - true if we support byte range seeks for restart, to do so each url must have a size and known crc32 up front
  #
  def self.compute_zip_size(urls)
    items_str = ''  # accumulate all the info used to generate the sha1_hash
    data_size = 0
    supports_seek = true
    zip_size = nil
    urls.each do |url|
      file_size = url[:size]
      crc32 = url[:crc32]
      supports_seek &= file_size && crc32  # only support seek if each and every on has a size and crc32
      items_str << url[:filename]
      items_str << url[:url]
      items_str << file_size.to_s
      items_str << crc32.to_s
      if data_size
        if file_size
          data_size += file_size.to_i
        else
          data_size = nil # not valid if one or more individual sizes is not known
        end
      end
    end

    if supports_seek || data_size
      # we can compute the total size since we have enough info
      mgr = WriteManager.new(BitBucket.new, data_size, SEEK_ONLY)
      # inject each file and add empty bytes for body of file
      # to compute our total size
      urls.each do |url|
        file_size = url[:size]
        mgr.start_file(url[:filename], file_size, url[:crc32])
        mgr.add_empty_bytes(file_size)
        mgr.finish_file
      end
      mgr.finish_all
      # ok, we should now have the total size
      zip_size = mgr.offset
    end
    signature = Digest::SHA1.hexdigest(items_str)

    [zip_size, data_size, signature, supports_seek]
  end


  # adds the next file to output into the stream,
  # assumes when you do this that the previous file
  # is done
  def start_file(name, data_size, crc32, date = Time.now)
    raise AnotherFilePending.new("Already sending another file, make sure you call finish_file when done.") if @entry
    prev_entry = @entries[0]
    @entry = use_64bit ? WriteEntry64.new(self, @offset, name, data_size, crc32, date) : WriteEntry.new(self, @offset, name, data_size, crc32, date)
    @entries << @entry
    @entry.write_local_header
  end

  # finishes out the current file
  def finish_file
    @entry.write_trailer
    @entry = nil
  end

  # push a chunk of data for the current file
  def push_data(chunk)
    raise NoCurrentFile.new("You need to have a current file in order to push data into the output stream") if @entry.nil?
    @entry.calc_crc32(chunk) if @entry.needs_crc32_calc
    #puts "crc push data: #{@entry.crc32.to_s(16)}"
    write_bytes(chunk)
  end

  # call this when there is nothing more to write, lets us finish up and
  # write the central directory
  def finish_all
    raise NotAllClosed.new("There is an unfinished file, you must call finish_file first.") if @entry
    @central_directory.write_central_directory
    @out_stream.close
  end

end

end # Zip64 module