AppConfiguration.class_eval do
  preference :printset_threshold, :decimal, :default => 35.00
  preference :allow_ssl_in_development_and_test, :boolean, :default => true
end