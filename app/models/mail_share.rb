#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class MailShare < Share
  attr_accessor :to

  
  def self.factory(user, params)
    @share = MailShare.new( params )

    #parse to field and create recipients for mail

    params[:to].split(';').each  do |person|
      rec = @share.recipients.build( :service => 'email',
                                         :name    => person,
                                         :address => person)
    end
    return @share
  end
end