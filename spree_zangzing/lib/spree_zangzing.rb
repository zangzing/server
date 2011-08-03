require 'spree_core'
require 'spree_zangzing_hooks'

module SpreeZangzing
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Spree::BaseController.asset_path = "/store%s"
      # MUST OVERRIDE Spree::Config.set(:default_print_sku => "EZP-00011")
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

    end

    config.to_prepare &method(:activate).to_proc
  end
end
