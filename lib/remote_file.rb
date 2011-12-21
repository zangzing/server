require 'net/http'
require 'digest/sha1'
require 'addressable/uri'

class IncompleteResponse < StandardError
  attr_reader :expected_size, :actual_size
  
  def initialize(expected, actual)
    @expected_size = expected
    @actual_size = actual
    super("#{actual} bytes retrieved instead of #{expected} expected")
  end
end

# Note: this cannot inherit from the Tempfile base class
# because we do not want the files deleting themselves since
# we use this to create files that are given to the Photo processing
# workflow and it needs to control the file lifetime
class RemoteFile < ::File
  CONTENT_DISPOSITION_FILENAME_REGEX = /filename=([A-Z,a-z,0-9_#-]+\.*[A-Z,a-z,0-9]*)/
  CHUNK_SIZE = 4096

  # do not use this directly, use read_remote_file instead
  # we always return with the file state closed and on an exception
  # we remove the file
  def initialize(path, tmpdir, options)
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
      self.close
      validate_size
    rescue Exception => ex
      # clean up if something went wrong
      self.close rescue nil
      File.delete(file_path) rescue nil
      raise ex
    end
  end

  # this call reads the remote file and returns the local file path
  # if any exception occurs the file will have been deleted in the exception
  # handler for the init
  # in all cases the file has been closed
  # an exception will be thrown on any error
  def self.read_remote_file(path, tmpdir = Dir::tmpdir, options = {})
    file = RemoteFile.new(path, tmpdir, options)
    return file.path
  end

  def options
    @options
  end

  def fetch
    target_uri = @remote_path
    follow_redirect = false
    begin

      # we switched to the addressable gem because it does a better job
      # parsing urls than the built in URI module
      uri = Addressable::URI::parse(target_uri)


      # addressable gem doesn't seem to always set port correctly for https urls
      # so check and set if necessary
      port = uri.port
      if uri.scheme == 'https' && port.nil?
        port = 443
      end

      http = Net::HTTP.new(uri.host, port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http.request_get(uri.request_uri, @options) do |remote_side|
        follow_redirect = remote_side.is_a?(Net::HTTPMovedPermanently) || remote_side.is_a?(Net::HTTPMovedTemporarily)
        if remote_side.code =~ /4\d\d/i #error 4xx
          raise Net::HTTPError.new("#{remote_side.code}: #{remote_side.message}", remote_side)
        elsif remote_side.code =~ /5\d\d/i #error 5xx
          raise Net::HTTPRetriableError.new("#{remote_side.code}: #{remote_side.message}", remote_side)
        end
        unless follow_redirect
          @content_type = remote_side['content-type']
          unless remote_side['transfer-encoding']=='chunked'
            @content_length = remote_side['content-length'].to_i rescue nil
          end
          if remote_side['content-disposition'] =~ CONTENT_DISPOSITION_FILENAME_REGEX
            @original_filename = $1
          end
          remote_side.read_body do |chunk|
            self.write chunk
          end
        else
          target_uri = remote_side['location']
          #remote_side.instance_variable_set(:read, true) #Do not read the body
        end
      end
    end while follow_redirect
    self.rewind
    self
  end

  def original_filename
    @original_filename
  end
  
  def content_length
    @content_length || 0
  end

  def content_type
    @content_type
  end
  
  def validate_size
    self_size = File.size(self.path)
    raise IncompleteResponse.new(content_length, self_size) if !content_length.zero? && (content_length > self_size)
    true
  end
end