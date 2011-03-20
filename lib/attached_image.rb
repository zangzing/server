#
# This class wraps behavior for attached images
# it provides resizing and s3 related services
#
# To use this you must write a child class that provides
# methods to customize behavior of the base class.  See
# PiconAttachedImage and PhotoAttachedImage for examples.
#
# To use this class you create an instance of it and associate
# it with the model it is tied to along with the base name
# of the photo field you want to work with (objname).
# Se assume there are fields defined in the db for
# objname_bucket
# objname_updated_at
# objname_path
# objname_file_size
# objname_content_type
#
# if you require resizing of your photo object your
# child class should override the sizes method
# to return your custom sizes array that is used
# to generate the proper ImageMagick command for
# the resizing operation.  See the PhotoAttachedImage
# class for an example.
#
class AttachedImage
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  # photo suffixes for naming
  ORIGINAL =  'o'
  LARGE =     'l'
  MEDIUM =    'm'
  THUMB =     't'
  STAMP =     's'

  TRACE_CATEGORY = :task

  # return the array of s3 buckets we can use
  def self.buckets
    @@buckets ||= PhotoGenHelper.s3_buckets
  end

  # grab a bucket to use at random amongst our set
  # so that Photos are distributed across the buckets
  def self.pick_bucket
    buckets[rand(buckets.count)]
  end

  def s3_headers
    {
      "x-amz-storage-class" => "REDUCED_REDUNDANCY",
      "Expires" => "#{1.year.from_now.httpdate}"
    }
  end

  # customize this in the child class if you want a different s3
  # privacy policy
  def s3_privacy_policy
    :public_read
  end
  
  # return the array of prefixes to ImageMagick operations
  # the child should override this if it has more than just the
  # original size to operate on - these need to be defined
  # in order from largest to smallest size - See PhotoAttachedImage
  # for an example
  def sizes
    @@sizes ||= []
  end

  # make a helper and set up the dynamic method references to the model we are
  # associated with
  def initialize(model, field_name)
    @dyn_bucket = model.method((field_name + "_bucket").to_sym)
    @dyn_bucket_set = model.method((field_name + "_bucket=").to_sym)
    @dyn_updated_at = model.method((field_name + "_updated_at").to_sym)
    @dyn_updated_at_set = model.method((field_name + "_updated_at=").to_sym)
    @dyn_path = model.method((field_name + "_path").to_sym)
    @dyn_path_set = model.method((field_name + "_path=").to_sym)
    @dyn_content_type = model.method((field_name + "_content_type").to_sym)
    @model = model
  end

  def bucket
    @dyn_bucket.call
  end

  def bucket=(val)
    @dyn_bucket_set.call(val)
  end

  def updated_at
    @dyn_updated_at.call
  end

  def updated_at=(val)
    @dyn_updated_at_set.call(val)
  end

  def path
    @dyn_path.call
  end

  def path=(val)
    @dyn_path_set.call(val)
  end

  def content_type
    @dyn_content_type.call
  end

  def model
    @model
  end




  # make the key to use for storing the item in s3 with the given
  # suffix
  def self.build_s3_key(prefix, image_id, suffix)
    "#{prefix}#{image_id}-#{suffix}"
  end

  # build the full url for the given image id and suffix
  def self.build_s3_url(bucket, prefix, image_id, suffix, time_stamp)
    key = build_s3_key(prefix, image_id, suffix)
    "http://#{bucket}.s3.amazonaws.com#{key}?" + time_stamp.to_i.to_s
  end

  # upload a single s3 photo with the given suffix
  def self.upload_s3_photo(file, bucket, key, options)
    file.rewind
    AWS::S3::S3Object.store(key, file, bucket, options)
  end

  # download a photo from s3 and return the local file
  def self.download_s3_photo(bucket, prefix, image_id, suffix)
    file_path = PhotoGenHelper.photo_download_dir + '/' + image_id + '-' + suffix + '-' + Process.pid.to_s + "-" + rand(9999999999).to_s
    file = File.new(file_path, "wb")
    AWS::S3::S3Object.stream(build_s3_key(prefix, image_id, suffix), bucket) do |chunk|
      file.write chunk
    end
    return file
  end

  # given the source file, we generate the resized files by building the ImageMagick
  # command, executing it and then return an array of maps containing the local path and
  # s3 keys - throws an exception if command failed
  def generate_resized_files(source_path, image_id)
    perform_action_with_newrelic_trace( :name => 'generate_resized_files',
                                        :category => TRACE_CATEGORY,
                                        :params => { :image_id => image_id }) do
      resize_dir = PhotoGenHelper.photo_resize_dir + '/'

      # build the command using the photo_sizes
      out_paths = []
      last = self.sizes.count - 1
      current = 0
      the_cmd = 'convert'
      args = '"' + source_path + '"' + " \\\n "
      custom = self.custom_commands
      args << custom + " " unless custom.nil?
      self.sizes.each do |map|
        # it is expected that the map only contain 1 key/value pair for each
        # array entry
        map.each do |suffix, option|
          local_path = resize_dir + image_id + '-' + suffix + ".jpg"
          s3_key = AttachedImage.build_s3_key(prefix, image_id, suffix)
          path_map = {:local_path => local_path, :s3_key => s3_key}
          if current < last
            # not the last one so gets normal treatment
            args << option + " -write " + '"' + local_path + '"' + " \\\n "
          else
            # special case on the last one due to strange ImageMagick command form
            args << option + ' "' + local_path + '"'
          end
          out_paths << path_map
          current += 1
        end
      end
      ZZ::CommandLineRunner.run(the_cmd, args)
      return out_paths
    end    
  end


  # remove a single photo from s3 - does not throw an
  # exception if file not found
  def self.remove_s3_photo(image_bucket, key)
    AWS::S3::S3Object.delete key, image_bucket
  rescue AWS::S3::NoSuchKey => ex
    # just ignore this one
  end

  # remove all the keys specified, ignores any errors
  def self.remove_s3_photos(image_bucket, keys)
    keys.each do |key|
      remove_s3_photo(image_bucket, key) rescue nil
    end
  end


  # remove the original and any other sizes from s3 storage
  def remove
    path = self.path
    if (path != nil)
      bucket = self.bucket
      AttachedImage.remove_s3_photo(bucket, build_s3_key(prefix, image_id, PhotoGenHelper.ORIGINAL))
      # now remove resized photos
      self.sizes.each do |suffix, options|
        AttachedImage.remove_s3_photo(bucket, build_s3_key(prefix, image_id, suffix))
      end
    end
  end


  # download the original image and perform resize operations on it
  # to produce files that are then ready to be uploaded
  def resize_photos()
    begin
      bucket = self.bucket
      image_id = model.guid_part
      # download the original file
      original_file = AttachedImage.download_s3_photo(bucket, prefix, image_id, ORIGINAL)
      original_file_path = original_file.path
      original_file.close

      # now that we have pulled in the original file, use it to generate the resized photos all in one call
      file_map = generate_resized_files(original_file_path, image_id)

    rescue => ex
      Rails.logger.debug("Photo resizing failed: " + ex)
      raise ex
    ensure
      File.delete(original_file_path) rescue nil
    end
    Rails.logger.debug("Photo resizing finished")
    file_map
  end

  def s3_options(content_type, metadata)
    options = {
        :content_type => content_type,
        :access => s3_privacy_policy
    }.merge(s3_headers)
    options.merge(metadata) unless metadata.nil?
  end
  
  # the map specified is an array of file_infos
  #[{:local_path => "upload/path", :s3_key=>"storage_key_for_this_file},...]
  #
  def upload_photos(file_map)
    bucket = self.bucket
    # we only call this once per operation so the custom_metadata can also reset any state it cares about
    # without worrying about being called multiple times
    meta = custom_metadata
    options = s3_options(content_type, meta)
    # walk the list of files to upload
    file_map.each do |file_info|
      local_file_path = file_info[:local_path]
      file = File.open(local_file_path, "rb")
      key = file_info[:s3_key]
      content_type = resized_content_type
      AttachedImage.upload_s3_photo(file, bucket, key, options)
      file.close
    end
  end

  def resize_and_upload_photos
    begin
    file_map = resize_photos
    upload_photos(file_map)
    rescue => ex
      Rails.logger.debug("Photo resizing and upload failed: " + ex)
      raise ex
    ensure
      # get rid of any resized local files
      if file_map != nil
        file_map.each do |file_info|
          local_file_path = file_info[:local_path]
          File.delete(local_file_path) rescue nil
        end
      end
    end
    Rails.logger.debug("Photo resizing and upload finished")
  end


  # upload a single photo and update the photo related
  # state - this should only be used for the original file
  # not the resized ones as they derive their state from
  # the original
  #
  # We expect content_type and file_size to already have
  # been set before this call.  This is to avoid the extra
  # overhead of discovering them again because in general
  # they would have already been known so we don't want
  # to duplicate effort and overhead here.
  #
  def upload file
    path = self.path
    image_id = model.guid_part
    key = AttachedImage.build_s3_key(prefix, image_id, ORIGINAL)
    if (path.nil?)
      # first time in pick a bucket to store into
      bucket = AttachedImage.pick_bucket
      self.bucket = bucket
    else
      bucket = self.bucket
      # no need to remove it first since overwriting works fine
      #AttachedImage.remove_s3_photo(bucket, key)
    end
    time_stamp = Time.now
    self.updated_at = time_stamp
    content_type = self.content_type
    url = AttachedImage.build_s3_url(bucket, prefix, image_id, ORIGINAL, time_stamp)
    self.path = url
    AttachedImage.upload_s3_photo(file, bucket, key, s3_options(content_type, custom_metadata_original))
  end

  # build the url from this model and field
  def url suffix
    AttachedImage.build_s3_url(self.bucket, prefix, model.guid_part, suffix, self.updated_at)
  end

  # return all keys tied to this image
  # handy helper useful for the cleanup operation where
  # we no longer have the original object
  def all_keys
    image_id = model.guid_part
    key = AttachedImage.build_s3_key(prefix, image_id, ORIGINAL)
    keys = [key]
    # now see if any resized photos to go with
    self.sizes.each do |map|
      map.each do |suffix, option|
        key = AttachedImage.build_s3_key(prefix, image_id, suffix)
        keys << key
      end
    end
    keys
  end

  # stuff that children can override

  # abstract class the returns the key prefix for s3 storage
  def prefix
    raise "Child must implement a AttachedImage.prefix method"
  end

  # return the content type of the resized files
  # this can be overridden if your resizing generates something
  # other than jpegs
  def resized_content_type
    "image/jpeg"
  end

  # return any custom commands such as rotation
  # this string is applied before any of the size operations
  # and only on the whole set
  # you should not update the model related to this
  # until the custom_metadata call occurs
  #
  def custom_commands
    return nil
  end

  # tack on any custom data you want to go with the original
  def custom_metadata_original
    return nil
  end
  # generate the custom metadata headers to be stored along
  # with the resized objects return the object as a map
  # this call is made after the custom_commands call so this
  # is where you want to change the model state
  def custom_metadata
    return nil
  end
end
