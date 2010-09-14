class FollowActivity  < Activity
  attr_accessible :followed, :follower
  validates_presence_of :followed, :follower

  # The user id is the follower
  # The payload is the followed id

  serialize :payload, Hash
  before_create :save_payload

  def self.factory( follower, followed)
    FollowActivity.create( :user => followed, :follower => follower, :followed => followed)   
    FollowActivity.create( :user => follower, :follower => follower, :followed => followed)
  end

  def save_payload
    self.payload = {:follower => @follower.id, :followed => @followed.id }
  end

  def followed
    @followed ||= User.find( self.payload[:followed])
  end

  def follower
    @follower ||= User.find( self.payload[:follower])
  end

  def followed=( f )
    if f.is_a?(User)
      @followed = f
    else
      raise new Exception("Argument must the Followed User");
    end
  end

  def follower=( f )
    if f.is_a?(User)
      @follower = f
    else
      raise new Exception("Argument must the Follower (A User)");
    end
  end
end
