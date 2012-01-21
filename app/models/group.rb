class Group < ActiveRecord::Base
  attr_accessible  :user_id, :name, :wrapped_user_id

  has_many :group_members,      :dependent => :delete_all
  belongs_to :user,             :foreign_key => 'wrapped_user_id'

  validates_presence_of   :name

  def self.max_insert_size
    @@safe_max_size ||= RawDB.safe_max_size(connection)
  end

  # make the special wrapped group name
  def self.make_wrapped_name(wrapped_id)
    name = "user-#{wrapped_id}"
  end

  # create the group that wraps the specified user
  def self.create_wrapped_user(wrapped_id)
    # not found, so create it
    name = make_wrapped_name(wrapped_id)
    group = Group.new(:name => name, :user_id => wrapped_id, :wrapped_user_id => wrapped_id)
    group.save!
    # fall through to create the group member

    # update or create the group member
    GroupMember.fast_update_members([[group.id, wrapped_id]])
    group
  end

  # return an array of groups
  def self.as_array(groups)
    result = []
    groups.each do |group|
      result << group.as_hash
    end
    result
  end

  # return a single group as a hash
  def as_hash
    hash = {
        :id => self.id,
        :name => self.name,
        :user_id => self.user_id,
        :wrapped_user_id => self.wrapped_user_id,
    }
    # if a wrapped user, add in user related info
    hash[:user] = Group.user_hash(user) if self.wrapped_user_id
    hash
  end

  # user hash with just group related fields
  def self.user_hash(user)
    {
      :id => user.id,
      :username => user.username,
      :profile_photo_url => user.profile_photo_url,
      :first_name => user.first_name,
      :last_name => user.last_name,
      :automatic => user.automatic,
    }
  end
end