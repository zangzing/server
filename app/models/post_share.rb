#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class PostShare < Share
  attr_accessor :twitter, :facebook

  @twitter  ="0"
  @facebook ="0"

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

  def deliver
    if super
      self.recipients.each do |rec|
        user = User.find(rec.address)
        user.send("identity_for_#{rec.service}").post(self.bitly, self.message)
      end
    end
  end

end
