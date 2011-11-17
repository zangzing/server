

# from documentation in dependencies.rb ...
#
# - autoload_paths
#
# The set of directories from which we may automatically load files. Files
# under these directories will be reloaded on each request in development mode,
# unless the directory also appears in autoload_once_paths.

if Rails.env == 'development'
  ActiveSupport::Dependencies.autoload_paths.each do |path|
    if(path.include?('spree_core-0.60.1') ||
       path.include?('spree_dash-0.60.1') ||
       path.include?('spree_zangzing') ||
       path.include?('spree_promo-0.60.1'))

      ActiveSupport::Dependencies.autoload_once_paths << path

      Rails.logger.info "adding path to autoload_once_paths: #{path}"
    end
  end
end

