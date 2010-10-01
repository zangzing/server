#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class EmailShare < Share
  attr_accessor :to

  validates_presence_of :recipients, :message => "must include at least 1 email address" 

  def self.factory(user, params)
    share = EmailShare.new( params )

    # if there are no recipients return
    return share if params[:to].nil?

    #parse to field and create recipients for mail, the field is an array of values
    params[:to].each  do |person|
        #TODO:validate addresses
       share.recipients.build( :service => 'email', :name    => person,:address => person)
    end
    return share
  end

  def deliver
     if self.sent_at.nil?
       self.recipients.each do |rec|
        Notifier.deliver_album_shared_with_you(self.user,rec.address,self.album)
       end
       self.sent_at = Time.now
       self.save
     end
  end
end