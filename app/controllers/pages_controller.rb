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


end
