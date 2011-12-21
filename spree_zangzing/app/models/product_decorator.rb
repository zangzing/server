Product.class_eval do
  unless defined?(CACHE_KEY)
    CACHE_KEY = "Spree.Product.all.1"
  end

  def as_json( options={} )

    {
          :id => id,
          :name => name,
          :description => description,
          :options =>  option_types.collect{ | ot | ot.as_json },
          :variants => variants.active.collect{ |v |  v.as_json },
          :image_url => images.first ? images.first.attachment.url(:small) : nil
    }
  end

  # clear all of our cached data
  def self.clear_caches
    CacheWrapper.delete(CACHE_KEY)
  end


  # fetch the data from the cache, if we don't have it cached fetch and then cache
  # returns result as json data
  # simple, no versioning for now
  def self.fetch_all_compressed_json
    json_str = CacheWrapper.read(CACHE_KEY)
    if json_str.nil?
      products = Product.where('deleted_at' => nil).order('created_at')
      json_str = JSON.fast_generate(products.as_json)
      json_str = ActiveSupport::Gzip.compress(json_str)
      CacheWrapper.write(CACHE_KEY, json_str, {:verify => true, :expires_in => 30.days})
    end
    json_str
  end


end

