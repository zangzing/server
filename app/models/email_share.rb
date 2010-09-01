#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class EmailShare < Share
  attr_accessor :to


  def self.factory(user, params)
    share = EmailShare.new( params )

    #parse to field and create recipients for mail

    params[:to].split(';').each  do |person|
       share.recipients.build( :service => 'email', :name    => person,:address => person)
    end
    return share
  end

  def deliver
     self.recipients.each do |rec|
      user = User.find( rec.address )
       Mailer.deliver_password_reset_instructions(self)
     end
     self.sent_at = Time.now
     self.save
  end

end