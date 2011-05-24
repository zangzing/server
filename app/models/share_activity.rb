#
#   Copyright 2011, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class ShareActivity < Activity
  attr_accessible :share
  validates_presence_of :share

  # The payload is the share id

  before_save :save_share_id

  def save_share_id
    self.payload = @share.id
  end

  def share
    @share ||= Share.find( self.payload )
  end

  def share=( s )
    if s.is_a?(Share)
      @share = s
    else
      raise new Exception("Argument must be a Share");
    end
  end

  def payload_valid?
    begin
      return true if share && share.subject        
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end
end

