AppConfiguration.class_eval do
  preference :default_print_sku, :string, :default => '10040'
  preference :allow_ssl_in_development_and_test, :boolean, :default => true
end