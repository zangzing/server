class Admin::AdminScreensController < Admin::AdminController

  def index
    #3rd Party Service Status
    @status = Hash.new()
    @page = 'status'
    [ 'flickr', 'facebook','bitly', 'twitter'].each do | service |
      @status[service] = self.send( service+'_status')
    end

    # System Component Status



    # Life Stats
    @today_photocount       = Photo.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_day])
    @this_week_photocount   = Photo.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_week])
    @today_albumcount       = Album.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_day])
    @this_week_albumcount   = Album.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_week])

    @today_usercount       = User.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_day])
    @yesterday_usercount   = User.count(:conditions => ["created_at >= ? AND created_at < ?", Time.now.at_beginning_of_day - 1.day, Time.now.at_beginning_of_day])
    @this_week_usercount   = User.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_week])
    @last_week_usercount   = User.count(:conditions => ["created_at >= ? AND created_at < ?", Time.now.at_beginning_of_week - 1.week, Time.now.at_beginning_of_week])
    @this_month_usercount  = User.count(:conditions => ["created_at >= ?", Time.now.at_beginning_of_month])
    @last_month_usercount  = User.count(:conditions => ["created_at >= ? AND created_at < ?", Time.now.at_beginning_of_month - 1.month, Time.now.at_beginning_of_month])

    @today_invited_usercount       = Invitation.count(:conditions => ["updated_at >= ? AND status <> 'pending'", Time.now.at_beginning_of_day])
    @yesterday_invited_usercount   = Invitation.count(:conditions => ["updated_at >= ? AND updated_at < ? AND status <> 'pending'", Time.now.at_beginning_of_day - 1.day, Time.now.at_beginning_of_day])
    @this_week_invited_usercount   = Invitation.count(:conditions => ["updated_at >= ? AND status <> 'pending'", Time.now.at_beginning_of_week])
    @last_week_invited_usercount   = Invitation.count(:conditions => ["updated_at >= ? AND updated_at < ? AND status <> 'pending'", Time.now.at_beginning_of_week - 1.week, Time.now.at_beginning_of_week])
    @this_month_invited_usercount  = Invitation.count(:conditions => ["updated_at >= ? AND status <> 'pending'", Time.now.at_beginning_of_month])
    @last_month_invited_usercount  = Invitation.count(:conditions => ["updated_at >= ? AND updated_at < ? AND status <> 'pending'", Time.now.at_beginning_of_month - 1.month, Time.now.at_beginning_of_month])

    @health_check = health_check
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

  protected

  def append_time(start_time)
    end_time = Time.now
    format(" - took %.3f </p>", end_time.to_f - start_time.to_f)
  end


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

        curr_check = "<p>Redis ACL connectivity check for: #{RedisConfig.config[:redis_acl_server]} - "
        status_msg << curr_check
        start_time = Time.now
        SystemTimer.timeout_after(max_time_per_check) do
          full_check = false
          if full_check
            status_msg << "Full check"
            # a more thorough check than just ping
            # make a dummy Album and add a user to check redis for ACL
            a = AlbumACL.new("health_check_album")
            a.add_user "health_check_user", AlbumACL::ADMIN_ROLE
            a.remove_acl
          else
            # just your basic ping check
            status_msg << "Ping check"
            redis = ACLManager.get_global_redis
            redis.ping
          end
        end
        status_msg << append_time(start_time)

        curr_check = "<p>Database connectivity check"
        start_time = Time.now
        SystemTimer.timeout_after(max_time_per_check) do
          # build a query that hits the database but does not return any actual data
          # to minimize performance impact
          status_msg << curr_check
          @photo = Photo.first(:conditions => ["TRUE = FALSE"])
        end
        status_msg << append_time(start_time)

        curr_check = "<p>ZZA Server check"
        status_msg << curr_check
        start_time = Time.now
        if ZZ::ZZA.unreachable? then
          raise "ZZA server is not reachable."
        end
        status_msg << append_time(start_time)
      end

      status_msg << "<p>App Servers: #{Server::Application.config.deploy_environment.all_app_servers}</p>"
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