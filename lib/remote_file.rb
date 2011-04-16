require 'net/http'
require 'digest/sha1'

# Note: this cannot inherit from the Tempfile base class
# because we do not want the files deleting themselves since
# we use this to create files that are given to the Photo processing
# workflow and it needs to control the file lifetime
class RemoteFile < ::File
  CONTENT_DISPOSITION_FILENAME_REGEX = /filename=([A-Z,a-z,0-9_#-]+\.*[A-Z,a-z,0-9]*)/
  CHUNK_SIZE = 4096

  def initialize(path, tmpdir = Dir::tmpdir, options = {})
    begin
      @original_filename  = File.basename(path)
      @remote_path        = path
      @content_type       = 'application/x-octet-stream'
      @options            = options
      # generate a unique name
      digest = Digest::SHA1.hexdigest(path + Time.now.to_i.to_s + rand(99999999).to_s)
      file_path = tmpdir + "/" + digest
      super file_path, "w+b"
      fetch
    rescue Exception => ex
      # clean up if something went wrong
      self.close rescue nil
      File.delete(file_path) rescue nil
      raise ex
    end
  end

  def options
    @options
  end

  def fetch
    uri = URI::parse(@remote_path)
    self.binmode if is_windows?
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http.request_get(uri.path, @options) do |remote_side|
      @content_type = remote_side.header['content-type']
      if remote_side.header['content-disposition'] =~ CONTENT_DISPOSITION_FILENAME_REGEX
        @original_filename = $1
      end
      remote_side.read_body do |chunk|
        self.write chunk
      end
    end

    self.rewind
    self
  end

  def original_filename
    @original_filename
  end

  def content_type
    @content_type
  end

  def is_windows?
    RUBY_PLATFORM =~ /(win|w)32$/
  end
end