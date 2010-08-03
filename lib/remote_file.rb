require 'open-uri'
require 'digest/sha1'

class RemoteFile < ::Tempfile
  CONTENT_DISPOSITION_FILENAME_REGEX = /filename=([A-Z,a-z,0-9_#-]+\.*[A-Z,a-z,0-9]*)/

  def initialize(path, tmpdir = Dir::tmpdir, options = {})
    @original_filename  = File.basename(path)
    @remote_path        = path
    @options            = options
    @content_type = 'application/x-octet-stream'

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
    self.binmode if is_windows?
    self.write string_io.read
    self.rewind
    self
  end

  def original_filename
    @original_filename
  end

  def content_type
=begin
    type = (self.path.match(/\.(\w+)$/)[1] rescue "octet-stream").downcase
    case type
    when %r"jp(e|g|eg)"            then "image/jpeg"
    when %r"tiff?"                 then "image/tiff"
    when %r"png", "gif", "bmp"     then "image/#{type}"
    when "txt"                     then "text/plain"
    when %r"html?"                 then "text/html"
    when "js"                      then "application/js"
    when "csv", "xml", "css"       then "text/#{type}"
    else
      # On BSDs, `file` doesn't give a result code of 1 if the file doesn't exist.
      content_type = (Paperclip.run("file", "--mime-type", self.path).split(':').last.strip rescue "application/x-#{type}")
      content_type = "application/x-#{type}" if content_type.match(/\(.*?\)/)
      content_type
    end
=end
  @content_type
  end

  def is_windows?
    RUBY_PLATFORM =~ /(win|w)32$/
  end
end