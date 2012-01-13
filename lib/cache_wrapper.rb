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

    verify = !!options[:verify]
    log = !!options[:log]

    Rails.logger.info("CacheWrapper write: #{key}") if log

    write_ok = false
    # try up to limit times, each time we fail we
    # reset the connection if it is in a wait state
    2.times do |attempt|
      nowait(key) if attempt > 0  # turn off wait state since we are trying again
      write_ok = cache.write(key, value, options)
      Rails.logger.error("CacheWrapper write attempt: #{attempt+1} failed for key: #{key}") unless write_ok
      if write_ok && verify
        # verify it
        check_data = cache.read(key)
        write_ok = value == check_data
        Rails.logger.error("CacheWrapper write with verify attempt: #{attempt+1} failed for key: #{key}") unless write_ok
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

  def self.read(key, log = false)
    Rails.logger.info("CacheWrapper fetch: #{key}") if log
    value = cache.read(key)
    if log
      if value
        Rails.logger.info("CacheWrapper hit: #{key}")
      else
        Rails.logger.info("CacheWrapper miss: #{key}")
      end
    end
    value
  end

  def self.delete(key)
    cache.delete(key)
  end

  # init the cache, if memcache we use it directly
  # since we don't want the local cache behavior behind it
  def self.initialize_cache(cache_type, config, opts, *params)
    @@cache = nil
    if cache_type == :mem_cache_store
      # don't normally need logging so leave off for now
      #opts[:logger] = config.logger
      # bypass rails wrappers
      @@cache = MemCacheWrapper.new(MemCache.new(MemcachedConfig.server_list, opts))
    else
      config.cache_store = cache_type, *params
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
      result = @cache.set(key, value, expires_in.to_i, true)
    end
    !result.nil?  # if nil return false, true otherwise
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
    !result.nil?  # if nil return false, true otherwise
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
      Rails.logger.error "MemCacheWrapper, call failed: #{ex.message}"
    end
    result
  end

end