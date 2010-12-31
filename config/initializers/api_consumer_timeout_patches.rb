#Loading timeouts
SERVICE_CALL_TIMEOUT = YAML.load(File.read("#{Rails.root}/config/service_timeouts.yml"))

#Facebook (HyperGraph)
class HyperGraph
  class << self
    private
    def initialize_http_connection
      http = Net::HTTP.new(API_URL, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = http.open_timeout = SERVICE_CALL_TIMEOUT[:facebook]
      http
    end
  end
end

#Flickr (FlickRaw)
FlickRawOptions['timeout'] = SERVICE_CALL_TIMEOUT[:flickr]

#Google Contacts / Picasa (GData)
module GData
  module HTTP
    class DefaultService
      def make_request(request)
        url = URI.parse(request.url)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == 'https')
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = http.open_timeout = SERVICE_CALL_TIMEOUT[:google]

        case request.method
        when :get
          req = Net::HTTP::Get.new(url.request_uri)
        when :put
          req = Net::HTTP::Put.new(url.request_uri)
        when :post
          req = Net::HTTP::Post.new(url.request_uri)
        when :delete
          req = Net::HTTP::Delete.new(url.request_uri)
        else
          raise ArgumentError, "Unsupported HTTP method specified."
        end

        case request.body
        when String
          req.body = request.body
        when Hash
          req.set_form_data(request.body)
        when File
          req.body_stream = request.body
          request.chunked = true
        when GData::HTTP::MimeBody
          req.body_stream = request.body
          request.chunked = true
        else
          req.body = request.body.to_s
        end

        request.headers.each do |key, value|
          req[key] = value
        end

        request.calculate_length!

        res = http.request(req)

        response = Response.new
        response.body = res.body
        response.headers = Hash.new
        res.each do |key, value|
          response.headers[key] = value
        end
        response.status_code = res.code.to_i
        return response
      end
    end
  end
end

#Kodak Gallery (KodakConnector)
KodakConnector.http_timeout = SERVICE_CALL_TIMEOUT[:kodak]

#Windows Live
class WindowsLiveLogin
  def fetch(url)
    url = URI.parse url
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")
    http.read_timeout = http.open_timeout = SERVICE_CALL_TIMEOUT[:mslive]
    http.request_get url.request_uri
  end
end


#Generic OAuth patch
module OAuth
  class Consumer
  protected
    def create_http(_url = nil)
      if !request_endpoint.nil?
       _url = request_endpoint
      end
      if _url.nil? || _url[0] =~ /^\//
        our_uri = URI.parse(site)
      else
        our_uri = URI.parse(_url)
      end
      if proxy.nil?
        http_object = Net::HTTP.new(our_uri.host, our_uri.port)
      else
        proxy_uri = proxy.is_a?(URI) ? proxy : URI.parse(proxy)
        http_object = Net::HTTP.new(our_uri.host, our_uri.port, proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
      end
      http_object.use_ssl = (our_uri.scheme == 'https')
      http_object.read_timeout = http_object.open_timeout = @options[:http_timeout] if @options[:http_timeout]

      if @options[:ca_file] || CA_FILE
        http_object.ca_file = @options[:ca_file] || CA_FILE
        http_object.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http_object.verify_depth = 5
      else
        http_object.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http_object
    end
  end
end

#PhotobucketConnector
PhotobucketConnector.http_timeout = SERVICE_CALL_TIMEOUT[:photobucket]

#Shutterfly Connector
ShutterflyConnector.http_timeout = SERVICE_CALL_TIMEOUT[:shutterfly]

#Smugmug Connector
SmugmugConnector.http_timeout = SERVICE_CALL_TIMEOUT[:smugmug]

#Yahoo Connector
YahooConnector.http_timeout = SERVICE_CALL_TIMEOUT[:yahoo]


#Twitter
module TwitterOAuth
  class Client
    private

    def consumer
      @consumer ||= OAuth::Consumer.new(
        @consumer_key,
        @consumer_secret,
        {
          :site => 'http://api.twitter.com', :request_endpoint => @proxy,
          :http_timeout => SERVICE_CALL_TIMEOUT[:twitter]
        }
      )
    end
  end
end
