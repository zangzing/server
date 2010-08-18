require 'open-uri'
require 'digest/sha1'

class RemoteFile < ::Tempfile
  CONTENT_DISPOSITION_FILENAME_REGEX = /filename=([A-Z,a-z,0-9_#-]+\.*[A-Z,a-z,0-9]*)/

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
    string_io = OpenURI.send(:open, @remote_path, @options)
    @content_type = string_io.meta['content-type']
    if string_io.meta['content-disposition'] =~ CONTENT_DISPOSITION_FILENAME_REGEX
      @original_filename = $1
    end
    unless @original_filename.include?('.') && (@content_type == 'x-octet-stream')
      extension = @content_type.split('/').last
      @original_filename += ".#{extension}"
    end

    self.binmode if is_windows?
    self.write string_io.read
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