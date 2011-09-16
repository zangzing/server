
# This class provided helper methods for s3 upload and photo generation
class PhotoGenHelper
  def self.init
    @@zconfig = Server::Application.config
    # set default unless it's already been set
    zconfig.photo_upload_dir = Dir::tmpdir + '/photo_uploads' unless zconfig.respond_to? 'photo_upload_dir'
    # ensure our photo upload directory is ready to go
    `mkdir -p #{zconfig.photo_upload_dir}`
    zconfig.photo_download_dir = Dir::tmpdir + '/photo_downloads' unless zconfig.respond_to? 'photo_download_dir'
    # ensure our photo upload directory is ready to go
    `mkdir -p #{zconfig.photo_download_dir}`
    zconfig.photo_resize_dir = Dir::tmpdir + '/photo_resize' unless zconfig.respond_to? 'photo_resize_dir'
    # ensure our photo upload directory is ready to go
    `mkdir -p #{zconfig.photo_resize_dir}`

    s3config = YAML::load(ERB.new(File.read("#{Rails.root}/config/s3.yml")).result)[Rails.env].recursively_symbolize_keys!
    zconfig.s3_access_key_id = s3config[:access_key_id]
    zconfig.s3_secret_access_key = s3config[:secret_access_key]
    zconfig.s3_buckets = s3config[:buckets]
    zconfig.s3_reduced_redundancy = s3config[:reduced_redundancy]

    @@s3 = RightAws::S3Interface.new(zconfig.s3_access_key_id, zconfig.s3_secret_access_key, {:logger => Rails.logger})
  end

  def self.s3
    @@s3
  end

  def self.zconfig
    @@zconfig
  end

  def self.photo_download_dir
    zconfig.photo_download_dir
  end

  def self.photo_upload_dir
    zconfig.photo_upload_dir
  end

  def self.photo_resize_dir
   zconfig.photo_resize_dir
  end

  def self.s3_access_key_id
    zconfig.s3_access_key_id
  end

  def self.s3_secret_access_key
    zconfig.s3_secret_access_key
  end

  def self.s3_buckets
    zconfig.s3_buckets
  end

  def self.s3_reduced_redundancy
    zconfig.s3_reduced_redundancy
  end
end

# set up helper globally once
PhotoGenHelper.init

