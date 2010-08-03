class Hash
  def to_url_params
    self.map { |k,v| "#{k.to_s}=#{CGI.escape(v.to_s)}"}.join("&")
  end
end