class SystemSetting < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.[]=(key, value)
    exisiting = find_by_name!(key)
    exisiting.update_attribute(:value, value)
  end

  def self.[](key)
    setting = find_by_name!(key)
    case setting.data_type
    when 'boolean'
      [true, 1, "1", "t", "true"].include?(setting.value)
    when 'decimal'
      BigDecimal.new(setting.value.to_s)
    when 'integer'
      setting.value.to_i
    when 'list'
      return setting.value if setting.value.is_a?(Array)
      setting.value.split("\n").collect{ |v| v.split(',') }
    else
      setting.value
    end
  end

end