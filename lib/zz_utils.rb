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

  # if value is nil return false, otherwise
  # return true or false
  def self.as_boolean(val)
    return false if val.nil?
    return true if val == true || val == 'true' || val == 1 || val == '1'
    return false if val == false || val == 'false' || val == 0 || val == '0'
    false # catch all for any non true or false value
  end

  # returns a safely filtered filename for mac an windows
  # by limiting length and filtering invalid chars
  def self.build_safe_filename(name, extension)
    limit = 254 - (extension.length + 1)  # leave room for .extension
    name = name[0..limit]

    # ok, now see if the name already has an extension that matches this extension, if so don't append
    if (name =~ /\.#{extension}$/i) == nil
      filename = "#{name}.#{extension}"
    else
      filename = name
    end
    # get rid of any invalid chars
    filename.gsub(/^\.|[\\\/:\*\?"<>|]/, '-')
  end

end