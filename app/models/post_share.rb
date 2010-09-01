#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class PostShare < Share
  attr_accessor :twitter, :facebook

  def self.factory(user, params)
    @share = PostShare.new( params )

    if params[:facebook] && params[:facebook ] != "0"
      @share.recipients.build( :service => 'facebook',:name    => user.name,:address => user.id)     
    end
    if params[:twitter] && params[:twitter ] != "0"
      @share.recipients.build( :service => 'twitter',:name    => user.name,:address => user.id)
    end
    return @share
  end

  def after_initialize
    @twitter  ="0"
    @facebook ="0"
  end


  def deliver
    self.recipients.each do |rec|
      user = User.find( rec.address )
      user.send("identity_for_#{rec.service}").post( self.message )
    end
    self.sent_at = Time.now
    self.save
  end

end
