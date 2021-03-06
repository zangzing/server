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

  # indicates the current sizing version scheme, this will be used
  # by a process that allows us to resize all old versioned photos
  # we record the size with the photo so we know which scheme
  # was applied and whether it needs upgrading or not.
  CURRENT_SIZE_VERSION = 2

  # photo suffixes based on size
  ORIGINAL          = 'o'
  FULL              = 'f'
  LARGE             = 'l'
  MEDIUM            = 'm'
  THUMB             = 't'
  STAMP             = 's'
  IPHONE_COVER      = 'ic'
  IPHONE_COVER_RET  = 'icr'
  IPHONE_GRID       = 'ig'
  IPHONE_GRID_RET   = 'igr'

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

  def self.original_suffix(suffix)
    suffix.nil? ? ORIGINAL : suffix.to_s
  end

  def s3_headers
    headers = {
      "Expires" => "#{1.year.from_now.httpdate}"
    }
    if PhotoGenHelper.s3_reduced_redundancy
      headers['x-amz-storage-class'] = 'REDUCED_REDUNDANCY'
    end
    headers
  end

  # customize this in the child class if you want a different s3
  # privacy policy
  def s3_privacy_policy
    'public-read'
  end
  
  # return the array of prefixes to ImageMagick operations
  # the child should override this if it has more than just the
  # original size to operate on - these need to be defined
  # in order from largest to smallest size - See PhotoAttachedImage
  # for an example
  def sizes
    @@sizes ||= []
  end

  # return the proper suffix based on our version mapped
  # to the current version - if a suffix is passed
  # that has no version mapping, we keep the suffix passed
  # this should only be the case when using the random suffix
  # for the original photo
  def suffix_based_on_version(suffix)
    # map of maps from the old versions to the latest
    @@version_map ||= {
        1 => {
            ORIGINAL            => ORIGINAL,
            FULL                => FULL,
            LARGE               => LARGE,
            MEDIUM              => MEDIUM,
            THUMB               => THUMB,
            STAMP               => STAMP,
            IPHONE_COVER        => MEDIUM,
            IPHONE_COVER_RET    => MEDIUM,
            IPHONE_GRID         => THUMB,
            IPHONE_GRID_RET     => THUMB
        }
    }

    photo_ver = model.size_version
    photo_ver = 1 if photo_ver.nil?
    if photo_ver != CURRENT_SIZE_VERSION
      # look up old version map
      suffix_map = @@version_map[photo_ver]
      # if no map the the old version, assume it is a direct 1:1 mapping
      # and just return the passed in suffix
      new_suffix = suffix_map.nil? ? suffix : suffix_map[suffix]
      suffix = new_suffix unless new_suffix.nil?  # when not found stick with suffix passed in
    end
    suffix
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
    "http://#{bucket}.s3.amazonaws.com/#{key}?" + time_stamp.to_i.to_s
  end

  # upload a single s3 photo with the given suffix
  def self.upload_s3_photo(file, bucket, key, options)
    file.rewind
    PhotoGenHelper.s3.store_object(:bucket => bucket, :key => key, :data => file, :headers => options)
  end

  # duplicate a single s3 photo with the given suffix
  def self.copy_s3_photo(src_bucket, src_key, dst_bucket, dst_key, headers)
    PhotoGenHelper.s3.copy(src_bucket, src_key, dst_bucket, dst_key, :replace, headers)
  end

  # download a photo from s3 and return the local file
  def self.download_s3_photo(bucket, prefix, image_id, suffix)
    file_path = PhotoGenHelper.photo_download_dir + '/' + image_id + '-' + suffix + '-' + Process.pid.to_s + "-" + rand(9999999999).to_s
    file = File.new(file_path, "wb")
    PhotoGenHelper.s3.retrieve_object(:bucket => bucket, :key => build_s3_key(prefix, image_id, suffix)) do |chunk|
      file.write chunk
    end
    return file
  end

  # make our key and return it
  def key(suffix)
    AttachedImage.build_s3_key(prefix, model.guid_part, suffix)
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
      # make sure all resized photos are converted to sRGB
      args = '"' + source_path + '[0]"' + " -profile /data/global/profiles/sRGB.icm \\\n "
      custom = self.custom_commands
      args << custom + " " unless custom.nil?
      self.sizes.each do |map|
        # it is expected that the map only contain 1 key/value pair for each
        # array entry
        map.each do |suffix, options|
          cmd = options[:cmd]
          clone = options[:clone]
          local_path = resize_dir + image_id + '-' + suffix + ".jpg"
          s3_key = AttachedImage.build_s3_key(prefix, image_id, suffix)
          path_map = {:local_path => local_path, :s3_key => s3_key}
          if current < last
            # not the last one so gets normal treatment
            args << "\\( +clone " if clone
            args << cmd + " -write " + '"' + local_path + '"'
            args << " +delete \\)" if clone
            args << " \\\n "
          else
            # special case on the last one due to ImageMagick always doing an implicit -write
            args << cmd + ' "' + local_path + '"'
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
    PhotoGenHelper.s3.delete(image_bucket, key)
  rescue RightAws::AwsError => ex
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
      AttachedImage.remove_s3_photo(bucket, key(AttachedImage.original_suffix(model.original_suffix)))
      # now remove resized photos
      self.sizes.each do |suffix, options|
        AttachedImage.remove_s3_photo(bucket, key(suffix))
      end
    end
  end


  # download the original image and perform resize operations on it
  # to produce files that are then ready to be uploaded
  def resize_photos
    begin
      bucket = self.bucket
      image_id = model.guid_part
      # download the original file
      original_file = AttachedImage.download_s3_photo(bucket, prefix, image_id, AttachedImage.original_suffix(model.original_suffix))
      original_file_path = original_file.path
      original_file.close

      # now that we have pulled in the original file, use it to generate the resized photos all in one call
      file_map = generate_resized_files(original_file_path, image_id)

    rescue Exception => ex
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
        'Content-Type' => content_type,
        'x-amz-acl' => s3_privacy_policy
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
    options = s3_options(resized_content_type, meta)
    # walk the list of files to upload
    file_map.each do |file_info|
      local_file_path = file_info[:local_path]
      file = File.open(local_file_path, "rb")
      key = file_info[:s3_key]
      AttachedImage.upload_s3_photo(file, bucket, key, options)
      file.close
    end
  end

  def resize_and_upload_photos
    begin
    file_map = resize_photos
    time_stamp = Time.now
    self.updated_at = Time.now
    upload_photos(file_map)
    # indicate the sizing version - used to know if
    # we have the latest sizing scheme or an earlier one
    # whenever we upgrade photo sizes
    model.size_version = CURRENT_SIZE_VERSION
    rescue Exception => ex
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


  # prepare to move or copy object on s3
  def prepare_for_s3_store
    path = self.path
    image_id = model.guid_part
    original_suffix = AttachedImage.original_suffix(model.original_suffix)
    key = key(original_suffix)
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
    headers = s3_options(content_type, custom_metadata_original)
    url = AttachedImage.build_s3_url(bucket, prefix, image_id, original_suffix, time_stamp)
    self.path = url
    [bucket, key, headers]
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
  def upload(file)
    bucket, key, headers = prepare_for_s3_store
    AttachedImage.upload_s3_photo(file, bucket, key, headers)
  end

  # copy the source photo from s3 into a new s3 bucket
  def copy(src_bucket, src_key)
    dst_bucket, dst_key, headers = prepare_for_s3_store
    AttachedImage.copy_s3_photo(src_bucket, src_key, dst_bucket, dst_key, headers)
  end

  # build the url from this model and field
  # also take into account the size_version of
  # the photo for backwards compatability of
  # old photos that have not been upgraded to the
  # new sizes
  def url(suffix)
    suffix = suffix_based_on_version(suffix)
    AttachedImage.build_s3_url(self.bucket, prefix, model.guid_part, suffix, self.updated_at)
  end

  # return all keys tied to this image
  # handy helper useful for the cleanup operation where
  # we no longer have the original object
  def all_keys
    image_id = model.guid_part
    key = key(AttachedImage.original_suffix(model.original_suffix))
    keys = [key]
    # now see if any resized photos to go with
    self.sizes.each do |map|
      map.each do |suffix, option|
        key = key(suffix)
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
