require 'thin'
require 'json'
require 'em-http'
require 'event_machine_rpc'



class ZipAsyncApp < AsyncAppBase
  # build up some sample json data
  # used as:
  #
  # http://localhost:3031/zip_download?json_path=/data/tmp/42903.1322105375.3002.4367048555.json
  #
  def self.make_sample_json(count)
    urls = []
    count.times do |i|
      suffix = "-%06d" % i + ".jpg"
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
  def zip_download(env)
    body = ZipDeferrableBody.new(env, json_data)
  end
end

