class ReferenceDataMover

  def initialize
    #Initialize connection to S3
    s3_keys = YAML.load(File.read("#{Rails.root}/config/s3.yml"))[Rails.env]
    @s3 = RightAws::S3.new(s3_keys['access_key_id'], s3_keys['secret_access_key'], {:logger       =>Logger.new(STDOUT)})
    @bucket = @s3.bucket('products.zz')
    @db_config = Rails.application.config.database_configuration[Rails.env]
    @deploy_group = Server::Application.config.deploy_environment.zz[:deploy_group_name]
    @deploy_group = (@deploy_group && @deploy_group.length > 0 ? @deploy_group : 'localhost')
  end

  def export_commerce( tag='' )
    # we use mysqldump to export the catalog,
    # manual is here http://dev.mysql.com/doc/refman/5.6/en/mysqldump.html

    @output_file = Time.now().strftime( "%Y%m%d_%H%M%S_#{@deploy_group}_#{tag}.sql")
    tmpfile = Tempfile.new( @output_file )
    tmpfile.close()
    cmd =[]
    cmd << "mysqldump"   #command
    cmd << "-u#{@db_config['username']}"
    cmd << " -p#{@db_config['password']}" if @db_config['password']
    cmd << ( @db_config['host'] ? " -h#{@db_config['host']}" : "-h localhost" )
    cmd << "#{@db_config['database']}"
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
    cmd << "> #{tmpfile.path}"
    sh cmd.flatten.compact.join(" ").strip.squeeze(" ")
    
    tmpfile.open()
    @bucket.put( "catalog_export/#{@output_file}",  tmpfile )
  end

  def commerce_export_file_list
    @bucket.keys('prefix' => 'catalog_export').map{ |k| k.to_s }
  end

  def import_commerce( export_filename )
    key = @bucket.key( export_filename )
    sqlfile = Tempfile.new( key.to_s.gsub('catalog_export/','') )
    sqlfile.write( key.get() )
    sqlfile.close()
    
    cmd =[]
    cmd << "mysql"   #command
    cmd << "-u#{@db_config['username']}"
    cmd << " -p#{@db_config['password']}" if @db_config['password']
    cmd << ( @db_config['host'] ? " -h#{@db_config['host']}" : "-h localhost" )
    cmd << "--verbose"
    cmd << "--debug-info"
    cmd << "#{@db_config['database']}"
    cmd << "< #{sqlfile.path}"
    sh cmd.flatten.compact.join(" ").strip.squeeze(" ")
  end
end