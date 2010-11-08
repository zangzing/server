class Notifier < ActionMailer::Base
  require 'vpim/vcard'

  if Rails.env == 'production'
    @@zzfrom = '"ZangZing Communications" <do-not-reply@zangzing.com>'
  else
    @@zzfrom = '"ZangZing '+Rails.env.capitalize+' Environment" <do-not-reply@zangzing.com>'
  end

  def contributors_added(contributor)
    from         contributor.album.long_email
    reply_to     contributor.album.long_email
    recipients   contributor.email
    subject      "You have been invited to contribute photos to '#{contributor.album.name}'!"
    sent_on       Time.now
    content_type "multipart/mixed"

    part(:content_type => "multipart/alternative")  do |p|
         p.part( :content_type => "text/plain",
                 :body => render_message('contributors_added.text.plain.erb',
                                         :user => contributor.album.user,
                                         :album => contributor.album,
                                         :album_mail => contributor.album.short_email))
         p.part( :content_type => "text/html",
                 :body => render_message('contributors_added.text.html.erb',
                                         :user => contributor.album.user,
                                         :album => contributor.album,
                                         :album_mail => contributor.album.short_email))
    end
    vcard = Vpim::Vcard::Maker.make2 do |vc|
      vc.add_name do |name|
        name.given = contributor.album.name
      end
      vc.add_email contributor.album.short_email
    end
    attachment :content_type => 'text/x-vcard',:filename => 'album.vcf', :body =>vcard.to_s
  end

  def upload_batch_finished( batch )
    from         batch.album.long_email
    reply_to     batch.album.long_email
    recipients   batch.user.email
    subject      "Your album "+batch.album.name+" is ready!"
    content_type "multipart/mixed"

    part(:content_type => "multipart/alternative")  do |p|
        p.part(:content_type => "text/plain",
               :body => render_message( 'upload_batch_finished.text.plain.erb',
                                        :album => batch.album,
                                        :album_url => album_url( batch.album ), :photos => batch.photos))
         p.part(:content_type => "text/html",
             :body => render_message( 'upload_batch_finished.text.html.erb',
                                      :album => batch.album,
                                      :album_url => album_url( batch.album ), :photos => batch.photos))
    end

    vcard = Vpim::Vcard::Maker.make2 do |vc|
      vc.add_name do |name|
        name.given = batch.album.name
      end
      vc.add_email batch.album.short_email
    end
    attachment :content_type => 'text/x-vcard',:filename => "#{batch.album.name}.vcf", :body =>vcard.to_s
  end

  def album_shared_with_you(from_user,to_address,album, message)
    from       @@zzfrom 
    recipients to_address
    subject "#{from_user.name} has shared ZangZing album: #{album.name} with you."
    content_type "text/html"
    body     :from_user => from_user, :album => album, :message=>message  
  end

  def you_are_being_followed( follower, followed)
    from @@zzfrom
    recipients followed.email
    subject    "#{follower.name} thinks the world of you"
    content_type "text/html"
    body       :follower => follower, :followed =>followed
  end

  def activation_instructions(user)
      subject       "Account Activation Instructions for your ZangZing Account"
      from          @@zzfrom
      recipients    user.email
      sent_on       Time.now
      content_type "text/html"
      body          :account_activation_url => activate_url(user.perishable_token)
  end

  def password_reset_instructions(user)
    subject       "ZangZing Password Reset Instructions"
    from          @@zzfrom
    recipients    user.email
    sent_on       Time.now
    content_type "text/html"
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def welcome(user)
    subject       "Welcome to ZangZing!"
    from          @@zzfrom
    recipients    user.email
    sent_on       Time.now
    content_type "text/html"
    body          :root_url => root_url
  end

  def test_email( to )
    from         @@zzfrom  
    recipients  to
    subject     "Test from ZangZing #{Rails.env.capitalize} Environment"
    body        "this is the body of the test"
  end

   

end
