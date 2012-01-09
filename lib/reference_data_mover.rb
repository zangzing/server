class ReferenceDataMover

  COMMERCE_DIR= 'catalog_export'
  EMAIL_DIR=    'email_export'

  def initialize
    #Initialize connection to S3
    @s3 = RightAws::S3.new(PhotoGenHelper.aws_access_key_id, PhotoGenHelper.aws_secret_access_key, {:logger       =>Logger.new(STDOUT)})
    @bucket = @s3.bucket('products.zz')
    @db_config = Rails.application.config.database_configuration[Rails.env]
    @deploy_group = ZZDeployEnvironment.env.zz[:deploy_group_name]
    @deploy_group = (@deploy_group && @deploy_group.length > 0 ? @deploy_group : 'localhost')
  end

  def export_commerce( tag='' )
    tables = %w(
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
    states
    tax_categories
    tax_rates
    taxonomies
    taxons
    variants
    zone_members
    zones
    )  #tables
    export( tables, COMMERCE_DIR,  tag)
  end

  def commerce_export_file_list
      @bucket.keys('prefix' => COMMERCE_DIR).map{ |k| k.to_s }
  end

  def export_email( tag='' )
      tables = %w(
      emails
      email_templates
      )  #tables
      export( tables, EMAIL_DIR,  tag)
  end

  def email_export_file_list
        @bucket.keys('prefix' => EMAIL_DIR).map{ |k| k.to_s }
  end

  def export( tables, export_dir='table_export', tag='' )
    # we use mysqldump to export the tables
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
    cmd << tables
    cmd << "> #{tmpfile.path}"
    sh cmd.flatten.compact.join(" ").strip.squeeze(" ")
    tmpfile.open()
    @bucket.put( "#{export_dir}/#{@output_file}",  tmpfile )
  end

  def import( export_filename )
    key = @bucket.key( export_filename )
    sqlfile = Tempfile.new( key.to_s.gsub( /.*_export\//,'') )
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