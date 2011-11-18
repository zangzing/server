require "active_support"
require "active_support/core_ext/hash"
ActiveSupport::XmlMini.backend = 'Nokogiri' #Switch backend for Hash.from_xml()

class Hash
  def to_url_params
    self.map { |k,v| "#{k.to_s}=#{CGI.escape(v.to_s)}"}.join("&")
  end

  # Destructively convert all keys to symbols, as long as they respond
  # to +to_sym+.
  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end unless method_defined?(:symbolize_keys!)


  def recursively_symbolize_keys! # :nodoc:
    Hash.recursively_symbolize_graph!(self)
    #hsh = symbolize_keys!
    #hsh.each { |k, v| hsh[k] = v.recursively_symbolize_keys! if v.kind_of?(Hash) }
    #hsh.each { |k, v| hsh[k] = v.map { |i| i.kind_of?(Hash) ? i.recursively_symbolize_keys! : i } if v.kind_of?(Array) }
    #return hsh
  end unless method_defined?(:recursively_symbolize_keys!)

  # recursively symbolize the object in place if it is an array or hash
  def self.recursively_symbolize_graph!(val)
    if val.kind_of?(Hash)
      val = val.symbolize_keys!
      val.each do |k, v|
        val[k] = recursively_symbolize_graph!(v)
      end
    end
    if val.kind_of?(Array)  # go deeper into the array
      val.each do |v|
        recursively_symbolize_graph!(v)
      end
    end
    val
  end unless method_defined?(:recursively_symbolize_graph!)

end

#x = { "h" => 1, "j" => 2, :d => 3, "f" => [[1,2,{ "z" => 22}],["w" => [4,5], "z" => "hello"]]}
#y = [[x]]
#Hash.recursively_symbolize_graph!(y)
