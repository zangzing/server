class Admin::AdminScreensController < Admin::AdminController

  def index
    #3rd Party Service Status
    @status = Hash.new()
    @page = 'status'
    [ 'flickr', 'facebook', 'mailchimp','bitly', 'twitter'].each do | service |
      @status[service] = self.send( service+'_status')
    end

    # System Component Status



    # Life Stats
    @today_photocount       = Photo.all(:conditions => ["created_at >= ?", Time.now.at_beginning_of_day]).count
    @this_week_photocount   = Photo.all(:conditions => ["created_at >= ?", Time.now.at_beginning_of_week]).count
    @today_albumcount       = Album.all(:conditions => ["created_at >= ?", Time.now.at_beginning_of_day]).count
    @this_week_albumcount   = Album.all(:conditions => ["created_at >= ?", Time.now.at_beginning_of_week]).count

    @today_usercount       = User.all(:conditions => ["created_at >= ?", Time.now.at_beginning_of_day]).count
    @yesterday_usercount   = User.all(:conditions => ["created_at >= ? AND created_at < ?", Time.now.at_beginning_of_day - 1.day, Time.now.at_beginning_of_day]).count
    @this_week_usercount   = User.all(:conditions => ["created_at >= ?", Time.now.at_beginning_of_week]).count
    @last_week_usercount   = User.all(:conditions => ["created_at >= ? AND created_at < ?", Time.now.at_beginning_of_week - 1.week, Time.now.at_beginning_of_week]).count
    @this_month_usercount  = User.all(:conditions => ["created_at >= ?", Time.now.at_beginning_of_month]).count
    @last_month_usercount  = User.all(:conditions => ["created_at >= ? AND created_at < ?", Time.now.at_beginning_of_month - 1.month, Time.now.at_beginning_of_month]).count

    @health_check = health_check;
  end

  def users
    @page = "users"
    @users = User.paginate(:page =>params[:page])
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

  protected
  def health_check
      max_total_time = 25.seconds
      max_time_per_check = 15.seconds
      z = ZZ::ZZA.new


      curr_check = ""  # need this here since used in rescue
      status_msg = ""

      # wrap the calls with a timeout check so we don't
      # end up potentially hanging here - we wrap the entire
      # set and then each individual test
      SystemTimer.timeout_after(max_total_time) do

        curr_check = "<p>Redis ACL connectivity check for: #{RedisConfig.config[:redis_acl_server]} - </p>"
        status_msg << curr_check
        SystemTimer.timeout_after(max_time_per_check) do
          full_check = false
          if full_check
            status_msg << "<p>Full check</p>"
            # a more thorough check than just ping
            # make a dummy Album and add a user to check redis for ACL
            a = AlbumACL.new("<p>health_check_album</p>")
            a.add_user "health_check_user", AlbumACL::ADMIN_ROLE
            a.remove_acl
          else
            # just your basic ping check
            status_msg << "<p>Ping check</p>"
            redis = ACLManager.get_global_redis
            redis.ping
          end
        end

        curr_check = "<p>Database connectivity check</p>"
        SystemTimer.timeout_after(max_time_per_check) do
          # build a query that hits the database but does not return any actual data
          # to minimize performance impact
          status_msg << curr_check
          @photo = Photo.first(:conditions => ["TRUE = FALSE"])
        end

        curr_check = "<p>ZZA Server check</p>"
        status_msg << curr_check
        if ZZ::ZZA.unreachable? then
          return "ZZA server is not reachable."
        end
      end

      #status_msg << "ZZA Thread state: " +  ZZ::ZZA.sender.thread.status.to_s

      z.track_event("health_check.ok", status_msg)
      ok_msg = '<p><b style="font-size: 120%; color: green;">OK</b>' + status_msg+ '</p>'

       return  ok_msg

    rescue Exception => ex
      msg = "<p><b style=\"font-size: 120%; color: green;\">ERROR</b></p> <p>HEALTH_CHECK ERROR during #{curr_check}Error: " + ex.message + "</p><p>" + status_msg+'</p>'
      z.track_event("health_check.fail", msg)
      Rails.logger.error msg
      # we use 509 as internal error so it doesn't get remapped by nginx
      return  msg
    end


end