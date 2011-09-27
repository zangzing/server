require 'readline'
require 'remote_file'

namespace :commerce do

  desc "Dump and Export Catalog to S3"
  task :export => :environment do
    # we use mysqldump to export the catalog,
    # manual is here http://dev.mysql.com/doc/refman/5.6/en/mysqldump.html
    db_config = Rails.application.config.database_configuration[Rails.env]
    deploy_group = Server::Application.config.deploy_environment.zz[:deploy_group_name]
    @output_file = Time.now().strftime( "%Y%m%d_%H%M_%S_#{deploy_group}.sql")
    cmd =[]
    cmd << "mysqldump"   #command
    cmd << "-u#{db_config['username']}"
    cmd << " -p#{db_config['password']}" if db_config['password']
    cmd << ( db_config['host'] ? " -h#{db_config['host']}" : "-h localhost" )
    cmd << "#{db_config['database']}"
    cmd << %w(
    assets
    calculators
    countries
    gateways
    option_types
    option_types_prototypes
    option_values
    option_values_variants
    payment_methods
    preferences
    product_groups
    product_groups_products
    product_option_types
    product_properties
    product_scopes
    products
    products_promotion_rules
    products_taxons
    promotion_rules
    promotions
    properties
    properties_prototypes
    prototypes
    shipping_categories
    shipping_methods
    tax_categories
    tax_rates
    taxonomies
    taxons
    variants
    zone_members
    zones
    )  #tables
    cmd << "> #{Rails.root}/#{@output_file}" if @output_file#capture output to file

    puts "\n\nDumping commerce catalog to local file"
    sh cmd.flatten.compact.join(" ").strip.squeeze(" ")


    #Export to S3
    puts "\nUploading to S3 bucket => products.zz"

    s3_keys = YAML.load(File.read("#{Rails.root}/config/s3.yml"))[Rails.env]
    s3 = RightAws::S3.new(s3_keys['access_key_id'], s3_keys['secret_access_key'], {:logger       =>Logger.new(STDOUT)})
    bucket = s3.bucket('products.zz')
    bucket.put( "catalog_export/#{@output_file}",  File.open("#{Rails.root}/#{@output_file}"), {}, 'public-read', {})
    puts "\n\n #{@output_file}\n\n"
  end

  desc "Import Commerce Catalog from S3"
  task :import do
    #Export to S3
    puts "\nLoading  S3 bucket => products.zz\n\n"
    s3_keys = YAML.load(File.read("#{Rails.root}/config/s3.yml"))[Rails.env]
    s3 = RightAws::S3.new(s3_keys['access_key_id'], s3_keys['secret_access_key'], {:logger       =>Logger.new(STDOUT)})
    bucket = s3.bucket('products.zz')
    keys = bucket.keys('prefix' => 'catalog_export')

    keys.each_with_index do |key , i|
      puts " #{i+1}.- #{key.to_s.gsub('catalog_export/','')}"
    end
    print "Enter # of file  you would like to import?"
    index = Readline.readline().to_i
    key = keys[index -1]
    filename = key.to_s.gsub('catalog_export/','')

    path = RemoteFile.read_remote_file(key.public_link)

    
    db_config = Rails.application.config.database_configuration[Rails.env]
    cmd =[]
    cmd << "mysql"   #command
    cmd << "-u#{db_config['username']}"
    cmd << " -p#{db_config['password']}" if db_config['password']
    cmd << ( db_config['host'] ? " -h#{db_config['host']}" : "-h localhost" )
    cmd << "#{db_config['database']}"
    cmd << "< #{path}"
    puts "\n\nImporting catalog into commerce from S3 file #{filename}"
    sh cmd.flatten.compact.join(" ").strip.squeeze(" ")
  end

end

