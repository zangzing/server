# set up s3 globally once
s3config = YAML::load(ERB.new(File.read("#{Rails.root}/config/s3.yml")).result)[Rails.env].recursively_symbolize_keys!
Server::Application.config.s3_access_key_id = s3config[:access_key_id]
Server::Application.config.s3_secret_access_key = s3config[:secret_access_key]

AWS::S3::Base.establish_connection!(
        :access_key_id => Server::Application.config.s3_access_key_id,
       :secret_access_key => Server::Application.config.s3_secret_access_key
)


