# just adds some validation and logging around rails cache class
class CacheWrapper

  # perform a rails cache write but do a validation check
  # to make sure it was written.  Log an error and give up
  # after a retry.
  #
  # Adds a :verify flag to the options args
  #
  def self.write(key, value, options = {})

    arg_verify = options[:verify]
    verify = arg_verify.nil? ? false : arg_verify

    write_ok = false
    2.times do |attempt|
      write_ok = Rails.cache.write(key, value, options)
      Rails.logger.error("Memcache write verify attempt: #{attempt+1} failed for key: #{key}") unless write_ok
      if write_ok && verify
        # verify it
        check_data = Rails.cache.read(key)
        write_ok = value == check_data
        Rails.logger.error("Memcache write with verify attempt: #{attempt+1} failed for key: #{key}") unless write_ok
      end
      break if write_ok
    end
    write_ok
  end

  def self.read(key)
    Rails.cache.read(key)
  end

  def self.delete(key)
    Rails.cache.delete
  end

end