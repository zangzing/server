# handy global utility methods
class ZZUtils
  # verify that at least one of the options is present
  def self.require_at_least_one(options, required_options, raise_err = false)
    options.each_key do |key|
      return true if required_options.include?(key)
    end
    raise ArgumentError.new("Must have at least one required option, none were found") if raise_err
    false
  end

  # raises an error or returns false if not all options required are present
  # also allows you to specify a block that can perform a conversion operation
  # on the values
  def self.require_all(options, required_options, raise_err = false, &block)
    found_all = true  # assume all found until we find otherwise
    required_options.each do |key|
      if options.include?(key) == false
        found_all = false
        break
      end
      options[key] = block.call(key, options[key]) unless block.nil?
    end
    raise ArgumentError.new("Not all required arguments were specified") if raise_err && found_all == false
    found_all
  end
end