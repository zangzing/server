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
    response.headers["Content-Type"] = 'text/plain'

    hc = HealthChecker.health_check

    item = hc[:redis]
    status_msg = "Redis connectivity check for: #{item[:server]} - #{HealthChecker.status_msg(item)}\n"
    item = hc[:database]
    status_msg << "Database connectivity check - #{HealthChecker.status_msg(item)}\n"
    item = hc[:zza]
    status_msg << "ZZA Server check - #{HealthChecker.status_msg(item)}\n"

    if HealthChecker.all_ok(hc)
      msg = "OK\n" + status_msg
      render :status => 200, :text => msg
    else
      msg = "ERROR\nHEALTH_CHECK ERROR\n" + status_msg
      render :status => 509, :text => msg
    end

    return  msg
  end

end
