require 'spree_core'
require 'spree_zangzing_hooks'

module SpreeZangzing
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/../lib/zz)

    def self.activate
      Spree::BaseController.asset_path = "/store%s"
      initializer 'spree_zangzing.set_spree_configuration_values' do |app|
        puts "Initializing spree_zangzing"
        # Spree::Config.set( :logo => '/images/zz-logo.png')
        # Spree::Config.set(:default_print_sku => "10040")
        # Spree::Config.set( :allow_guest_checkout => true)
      end

      pre_load = ["../app/**/*_decorator*.rb","../lib/ezprints/**/*.rb"]
      pre_load.each do |g|
        glob = File.join(File.dirname(__FILE__), g)
        Dir.glob(glob) do |c|
          acts_as_production? ? require(c) : load(c)
        end
      end

    end

    # in a production environment we want require vs load
    # production defined here is photos_production or photos_staging
    def self.acts_as_production?
      case Rails.env
        when "photos_production", "photos_staging", "production"
          true
        else
          false
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end