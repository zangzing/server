require 'spree_core'
require 'spree_zangzing_hooks'

module SpreeZangzing
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/../lib/zz)

    def self.activate
       Spree::BaseController.asset_path = "/store%s"
       Spree::Config.set( :logo => '/images/zz-logo.png')
       initializer 'spree_zangzing.set_spree_configuration_values' do |app|
          puts "Initializing spree_zangzing"
          #Spree::Config.set( :logo => '/images/zz-logo.png')
	        # MUST OVERRIDE Spree::Config.set(:default_print_sku => "EZP-00011")
          # Spree::Config.set( :allow_guest_checkout => true)
       end

      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

    end

    config.to_prepare &method(:activate).to_proc
  end
end
