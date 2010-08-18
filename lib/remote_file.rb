require 'net/http'
require 'digest/sha1'

class RemoteFile < ::Tempfile
  CONTENT_DISPOSITION_FILENAME_REGEX = /filename=([A-Z,a-z,0-9_#-]+\.*[A-Z,a-z,0-9]*)/
  CHUNK_SIZE = 4096

  def initialize(path, tmpdir = Dir::tmpdir, options = {})
    @original_filename  = File.basename(path)
    @remote_path        = path
    @content_type       = 'application/x-octet-stream'
    @options            = options

    super Digest::SHA1.hexdigest(path), tmpdir
    fetch
  end

  def options
    @options
  end

  def fetch
    uri = URI::parse(@remote_path)
    self.binmode if is_windows?
    Net::HTTP.start(uri.host, uri.port) do |http|
      http.request_get(uri.path, @options) do |remote_side|
        @content_type = remote_side.header['content-type']
        if remote_side.header['content-disposition'] =~ CONTENT_DISPOSITION_FILENAME_REGEX
          @original_filename = $1
        end
        remote_side.read_body do |chunk|
          self.write chunk
        end
      end
    end
    unless @original_filename.include?('.') && (@content_type == 'x-octet-stream')
      extension = @content_type.split('/').last
      @original_filename += ".#{extension}"
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