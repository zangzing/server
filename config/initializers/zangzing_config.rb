# this class hold onto the zangzing_environment data from the same named yml
# use it for generic stuff that you'd like to control on a per environment basis
#
class ZangZingConfig
  def self.load
    @@zze_config = YAML::load(ERB.new(File.read("#{Rails.root}/config/zangzing_config.yml")).result)[Rails.env].recursively_symbolize_keys!
  end

  def self.zze_config
    @@zze_config
  end
end

# set up generic zangzing environment helper class
ZangZingConfig.load

