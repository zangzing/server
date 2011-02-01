class Admin::StatusController < Admin::AdminController

  def show
    @status = Hash.new()
    [ 'flickr', 'facebook', 'mailchimp','bitly', 'twitter'].each do | service |
      @status[service] = self.send( service+'_status')      
    end
  end

private
  def mailchimp_status
    begin
      ZZ::MailChimp.ping
    rescue ZZ::MailChimp::Error => e
      logger.warn "MailChimp Service Error: "+ e
      return false
    end
    true
  end

  def bitly_status
    begin
      Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key]).shorten( 'http://www.zangzing.com' )
    rescue BitlyError => e
      logger.error "Bitly Service Error: "+ e
      return false
    end
    true
  end

  def twitter_status
    Net::HTTP.get(URI.parse('http://api.twitter.com/1/help/test.json')) == "\"ok\""
  end

  def facebook_status
    begin
      JSON.parse(  Net::HTTP.get(URI.parse('http://graph.facebook.com/zangzing')) )['name'] == "ZangZing"
    rescue Exception => e
      logger.error "Facebook Service Error: "+ e
      return false
    end
    true
  end

  def flickr_status
    begin
     FlickRaw.api_key = FLICKR_API_KEYS[:api_key]
     FlickRaw.shared_secret = FLICKR_API_KEYS[:shared_secret]
     flickr.test().echo('ZangZing' => "Group Photo Sharing")['ZangZing'] == "Group Photo Sharing"
    rescue
      return false
    end
    true
  end

end