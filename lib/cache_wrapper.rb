require 'memcache'

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
    # try up to limit times, each time we fail we
    # reset the connection if it is in a wait state
    2.times do |attempt|
      nowait(key) if attempt > 0  # turn off wait state since we are trying again
      write_ok = cache.write(key, value, options)
      Rails.logger.error("Memcache write attempt: #{attempt+1} failed for key: #{key}") unless write_ok
      if write_ok && verify
        # verify it
        check_data = cache.read(key)
        write_ok = value == check_data
        if write_ok == false
          Rails.logger.error("Memcache write with verify attempt: #{attempt+1} failed for key: #{key}")
        end
      end
      break if write_ok
    end
    write_ok
  end

  def self.nowait(key)
    if cache.is_a?(MemCacheWrapper)
      cache.nowait(key)
    end
  end

  def self.cache
    @@cache ||= Rails.cache
  end

  def self.read(key)
    cache.read(key)
  end

  def self.delete(key)
    cache.delete(key)
  end

  # init the cache, if memcache we use it directly
  # since we don't want the local cache behavior behind it
  def self.initialize_cache(cache_type, config, timeout)
    @@cache = nil
    if cache_type == :mem_cache_store
      opts = {}
      opts[:logger] = config.logger
      opts[:timeout] = 1.5
      # bypass rails wrappers
      @@cache = MemCacheWrapper.new(MemCache.new(MemcachedConfig.server_list, opts))
    else
      config.cache_store = cache_type
    end
  end

end

class MemCacheWrapper
  attr_accessor :cache

  def initialize(cache)
    @cache = cache
  end

  def write(key, value, options = nil)
    result = nil
    safe_wrap do
      if options
        expires_in = options[:expires_in]
      end
      expires_in ||= 0
      result = @cache.set(key, value, expires_in, true)
    end
    result.nil? ? false : true
  end

  def read(key)
    result = nil
    safe_wrap do
      result = @cache.get(key, true)
    end
    result
  end

  def delete(key)
    result = nil
    safe_wrap do
      result = @cache.delete(key)
    end
    result.nil? ? false : true
  end

  # if server is dead, mark as undead so we
  # can try again
  def nowait(key)
    safe_wrap do
      @cache.nowait(key)
    end
  end

  def safe_wrap(&block)
    result = nil
    begin
      result = block.call
    rescue Exception => ex
      # log the error
      Rails.logger.error "CacheWrapper, call failed: #{ex.message}"
    end
    result
  end

end