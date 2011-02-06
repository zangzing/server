ActiveSupport::XmlMini.backend = 'Nokogiri' #Switch backend for Hash.from_xml()

class Hash
  def to_url_params
    self.map { |k,v| "#{k.to_s}=#{CGI.escape(v.to_s)}"}.join("&")
  end
  
  # A method to recursively symbolize all keys in the Hash class
  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        #v.recursively_symbolize_keys!
      end
    end
    self
  end
end