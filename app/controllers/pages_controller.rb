class PagesController < ApplicationController
  before_filter :require_user, :only => :contact


  def home
     @title = "Home"
     if current_user
       redirect_to user_url( current_user.username )
     else
       redirect_to join_url
     end
   end

  def inactive_acct

    
  end

  #
  # sample code for dynamic generation of a vcard
  #
#  def contact
#
#    if current_user
#      @title = current_user.name+"'s Contact Info"
#      @user = current_user
#      card = Vpim::Vcard::Maker.make2 do |maker|
#
#        maker.add_name do |name|
#              name.prefix = ''
#              name.given = @user.first_name
#              name.family = @user.last_name
#        end
#
#        maker.add_addr do |addr|
#              addr.preferred = true
#              addr.location = 'work'
#              addr.street = '243 Felixstowe Road'
#              addr.locality = 'Ipswich'
#              addr.country = 'United Kingdom'
#        end
#
#        maker.add_tel("(415) 294-1363")
#
#        maker.add_email(@user.email) { |e| e.location = 'work' }
#
#      end
#
#      send_data card.to_s,
#                :type => 'text/x-vcard',
#                :filename => @user.username+"_contact.vcf",
#                :disposition => 'attachment' and return
#    else
#      @title = "Contact"
#    end
#  end


  # method used by pingdom to check the health of the server
  def health_check
    max_total_time = 25.seconds
    max_time_per_check = 15.seconds
    z = ZZ::ZZA.new

    response.headers["Content-Type"] = 'text/plain'

    curr_check = ""  # need this here since used in rescue
    status_msg = ""

    # wrap the calls with a timeout check so we don't
    # end up potentially hanging here - we wrap the entire
    # set and then each individual test
    SystemTimer.timeout_after(max_total_time) do

      curr_check = "Redis ACL connectivity check for: #{RedisConfig.config[:redis_acl_server]} - "
      status_msg << curr_check
      SystemTimer.timeout_after(max_time_per_check) do
        full_check = false
        if full_check
          status_msg << "Full check\n"
          # a more thorough check than just ping
          # make a dummy Album and add a user to check redis for ACL
          a = OldAlbumACL.new("health_check_album")
          a.add_user "health_check_user", OldAlbumACL::ADMIN_ROLE
          a.remove_acl
        else
          # just your basic ping check
          status_msg << "Ping check\n"
          redis = OldACLManager.get_global_redis
          redis.ping
        end
      end

      curr_check = "Database connectivity check\n"
      SystemTimer.timeout_after(max_time_per_check) do
        # build a query that hits the database but does not return any actual data
        # to minimize performance impact
        status_msg << curr_check
        @photo = Photo.first(:conditions => ["TRUE = FALSE"])
      end

      curr_check = "ZZA Server check\n"
      status_msg << curr_check
      if ZZ::ZZA.unreachable? then
        raise "ZZA server is not reachable."
      end
    end

    #status_msg << "ZZA Thread state: " +  ZZ::ZZA.sender.thread.status.to_s

    #z.track_event("health_check.ok", status_msg)
    ok_msg = "OK\n" + status_msg

    render :status => 200, :text => ok_msg

  rescue Exception => ex
    msg = "ERROR\nHEALTH_CHECK ERROR during #{curr_check}Error: " + ex.message + "\n" + status_msg
    z.track_event("health_check.fail", msg)
    Rails.logger.error msg
    # we use 509 as internal error so it doesn't get remapped by nginx
    render :status => 509, :text => msg
  end

end
