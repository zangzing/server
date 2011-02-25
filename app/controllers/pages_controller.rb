class PagesController < ApplicationController
  before_filter :require_user, :only => :contact


  def home
     @title = "Home"
     if current_user
       redirect_to user_albums_url( current_user.username )
     end
   end
  
  def contact
    if current_user
      @title = current_user.name+"'s Contact Info"
      @user = current_user
      card = Vpim::Vcard::Maker.make2 do |maker|

        maker.add_name do |name|
              name.prefix = ''
              name.given = @user.first_name
              name.family = @user.last_name
        end

        maker.add_addr do |addr|
              addr.preferred = true
              addr.location = 'work'
              addr.street = '243 Felixstowe Road'
              addr.locality = 'Ipswich'
              addr.country = 'United Kingdom'
        end

        maker.add_tel("(415) 294-1363")

        maker.add_email(@user.email) { |e| e.location = 'work' }

      end

      send_data card.to_s,
                :type => 'text/x-vcard',
                :filename => @user.username+"_contact.vcf",
                :disposition => 'attachment' and return
    else
      @title = "Contact"
    end
  end
  
  def about
    @title ="About"
  end
  def help
    @title = "Help"
  end

  # method used by pingdom to check the health of the server
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

      curr_check = 'Database connectivity check'
      SystemTimer.timeout_after(max_time_per_check) do
        # build a query that hits the database but does not return any actual data
        # to minimize performance impact
        @photo = Photo.first(:conditions => ["TRUE = FALSE"])
      end

      curr_check = 'ZZA Server check'
      if ZZ::ZZA.unreachable? then
        raise "ZZA server is not reachable."
      end
    end

    z.track_event("health_check.ok", status_msg)
    render :status => 200, :text => "OK -- " + status_msg

  rescue Exception => ex
    msg = "HEALTH_CHECK ERROR during #{curr_check} : " + ex.message
    z.track_event("health_check.fail", msg)
    Rails.logger.error msg
    render :status => 503, :text => msg
  end

end
