require 'thin'
require 'json'
require 'em-http'
require 'event_machine_rpc'



class ZipAsyncApp
  # This is a template async response.
  AsyncResponse = [-1, {}, []].freeze
  ErrorResponse = [400, {}, []].freeze

  def initialize
    @request_count = 0
  end

  def request_count
    @request_count
  end

  def request_bump
    @request_count += 1
  end

  def logger
    AsyncConfig.logger
  end

  # build up some sample json data
  # used as:
  #
  # http://localhost:3001/test?json_path=/data/tmp/42903.1322105375.3002.4367048555.json
  #
  def self.make_sample_json(count)
    urls = []
    count.times do |i|
      suffix = "-%05d" % i + ".jpg"
      urls << { :url => 'http://4.zz.s3.amazonaws.com/i/df10e709-70c2-4cb1-adcd-3e20a5c35e84-o?1300228724',
                :size => 810436, :crc32 => nil, :create_date => nil,
                :filename => "file#{suffix}"}
    end
    data = {
        :user_context => {
            :user_type => 1, :user_id => 999, :user_ip => '111.111.111.111'
        },
        :album_name => 'zipper.zip',
        :album_id => 111,
        :urls => urls
    }
    EventMachineRPC.generate_json_file(data)
  end

  # we are being called to handle our url (/zip_download)
  def call(env)
    begin
      request_bump

      body = ZipDeferrableBody.new(env)
      if body.more_urls?
        # and away we go...
        body.fetch_next
        # tell thin we will be doing this async
        # the real work is kicked off by the next tick
        AsyncResponse
      else
        # called with nothing to do, error
        # add logging here
        ErrorResponse
      end
    rescue Exception => ex
      # log exception
      logger.error("EventMachine incoming request failed for #{env['REQUEST_PATH']} with: #{ex.message}")
      ErrorResponse
    end
  end

end

