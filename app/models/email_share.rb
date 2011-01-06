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
    if super
       self.recipients.each do |recipient |
          ZZ::Async::Email.enqueue( :album_shared_with_you, user.id, recipient.address, album.id, message )
       end
     end
  end

end