#
#   Copyright 2011 ZangZing LLC. All rights reserved. www.zangzing.com
##
Image.class_eval do

  has_attached_file :attachment,
                    :styles => { :mini => '48x48>', :small => '100x100>', :product => '240x240>', :large => '600x600>' },
                    :default_style => :product,
                    :storage => :s3,
                    :bucket => 'products.zz',
                    :s3_credentials => { :access_key_id =>     Server::Application.config.aws_access_key_id,
                                         :secret_access_key => Server::Application.config.aws_secret_access_key },
                    :url =>  ":s3_domain_url",
                    :path => "/products/:id/:style/:basename.:extension"

end