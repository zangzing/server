class Group < ActiveRecord::Base
  attr_accessible  :user_id, :name, :self_group

  has_many :group_members,              :dependent => :destroy

  validates_presence_of   :name

  # find or create the wrapped group for the specified user
  def self.find_or_create_wrapped_user(owner_id, wrapped_id, email)
    group = Group.find_by_wrapped_user_id(wrapped_id)
    email_id = nil
    if email
      #TODO when we have multiple emails, find a match, if no match use primary
    end
    if group.nil?
      # not found, so create it
      name = "wrapped.#{wrapped_id}"
      group = Group.new(:name => name, :user_id => owner_id, :wrapped_user_id => wrapped_id)
      # fall through to create the group member
    end
    # update or create
    GroupMember.fast_update_members([group.id, wrapped_id, email_id])
    group
  end

  # return a single group as a hash
  def as_hash
    {
        :id => self.id,
        :name => self.name,
        :user_id => self.user_id,
        :self_group => self.self_group,
    }
  end
end