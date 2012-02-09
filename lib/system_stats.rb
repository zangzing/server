class SystemStats
  def gather_stats
    #3rd Party Service Status
    status = Hash.new()
    [ 'flickr', 'facebook','bitly', 'twitter'].each do | service |
      status[service] = self.send( service+'_status')
    end

    # System Component Status

    hash = {
        :external_services => status,
        :photos => {
            :total => Photo.count,
            :today => Photo.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_day]),
            :yesterday => Photo.count(:conditions => ["created_at >= ? AND created_at < ?", Time.now.at_beginning_of_day - 1.day, Time.now.at_beginning_of_day]),
            :this_week => Photo.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_week]),
            :last_week => Photo.count(:conditions => ["created_at >= ? AND created_at < ?", Time.now.at_beginning_of_week - 1.week, Time.now.at_beginning_of_week]),
            :this_month => Photo.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_month]),
            :last_month => Photo.count(:conditions => ["created_at >= ? AND created_at < ?", Time.now.at_beginning_of_month - 1.month, Time.now.at_beginning_of_month])
        },
        :albums => {
            :total => Album.count(:conditions => ["type <> 'ProfileAlbum'"]),
            :today => Album.count(:conditions => ["type <> 'ProfileAlbum' AND created_at >= ?", Time.now.at_beginning_of_day]),
            :yesterday => Album.count(:conditions => ["type <> 'ProfileAlbum' AND created_at >= ? AND created_at < ?", Time.now.at_beginning_of_day - 1.day, Time.now.at_beginning_of_day]),
            :this_week => Album.count(:conditions => ["type <> 'ProfileAlbum' AND created_at >= ?", Time.now.at_beginning_of_week]),
            :last_week => Album.count(:conditions => ["type <> 'ProfileAlbum' AND created_at >= ? AND created_at < ?", Time.now.at_beginning_of_week - 1.week, Time.now.at_beginning_of_week]),
            :this_month => Album.count(:conditions => ["type <> 'ProfileAlbum' AND created_at >= ?", Time.now.at_beginning_of_month]),
            :last_month => Album.count(:conditions => ["type <> 'ProfileAlbum' AND created_at >= ? AND created_at < ?", Time.now.at_beginning_of_month - 1.month, Time.now.at_beginning_of_month])
        },
        :users => {
            :total => User.count(:conditions => ["auto_by_contact = false"]),
            :today => User.count(:conditions => ["auto_by_contact = false AND created_at >= ?", Time.now.at_beginning_of_day]),
            :yesterday => User.count(:conditions => ["auto_by_contact = false AND created_at >= ? AND created_at < ?", Time.now.at_beginning_of_day - 1.day, Time.now.at_beginning_of_day]),
            :this_week => User.count(:conditions => ["auto_by_contact = false AND created_at >= ?", Time.now.at_beginning_of_week]),
            :last_week => User.count(:conditions => ["auto_by_contact = false AND created_at >= ? AND created_at < ?", Time.now.at_beginning_of_week - 1.week, Time.now.at_beginning_of_week]),
            :this_month => User.count(:conditions => ["auto_by_contact = false AND created_at >= ?", Time.now.at_beginning_of_month]),
            :last_month => User.count(:conditions => ["auto_by_contact = false AND created_at >= ? AND created_at < ?", Time.now.at_beginning_of_month - 1.month, Time.now.at_beginning_of_month])
        },
        :invited_users => {
            :total => Invitation.count(:conditions => ["status <> 'pending'"]),
            :today => Invitation.count(:conditions => ["updated_at >= ? AND status <> 'pending'", Time.now.at_beginning_of_day]),
            :yesterday => Invitation.count(:conditions => ["updated_at >= ? AND updated_at < ? AND status <> 'pending'", Time.now.at_beginning_of_day - 1.day, Time.now.at_beginning_of_day]),
            :this_week => Invitation.count(:conditions => ["updated_at >= ? AND status <> 'pending'", Time.now.at_beginning_of_week]),
            :last_week => Invitation.count(:conditions => ["updated_at >= ? AND updated_at < ? AND status <> 'pending'", Time.now.at_beginning_of_week - 1.week, Time.now.at_beginning_of_week]),
            :this_month => Invitation.count(:conditions => ["updated_at >= ? AND status <> 'pending'", Time.now.at_beginning_of_month]),
            :last_month => Invitation.count(:conditions => ["updated_at >= ? AND updated_at < ? AND status <> 'pending'", Time.now.at_beginning_of_month - 1.month, Time.now.at_beginning_of_month])
        },
        :health_check => HealthChecker.health_check
    }
    hash
  end

private

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