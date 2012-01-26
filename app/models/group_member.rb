class GroupMember < ActiveRecord::Base
  extend ZZActiveRecordUtils

  attr_accessible  :group_id, :user_id, :email_id

  belongs_to :user

  # perform a bulk insert/update of group members
  # takes rows in the form
  # [ [group_id, user_id], ... ]
  # does an update on all of the rows specified in
  # a minimal number of queries
  def self.fast_update_members(rows)
    base_cmd = "INSERT INTO #{quoted_table_name}(group_id, user_id) VALUES "
    end_cmd = "ON DUPLICATE KEY UPDATE user_id = VALUES(user_id)"
    RawDB.fast_insert(connection, rows, base_cmd, end_cmd)
  end

  # returns an array of hashes given an array of members
  def self.as_array(members)
    result = []
    members.each do |member|
      result << member.as_hash
    end
    result
  end

  # returns a single member in hash form
  def as_hash
    hash = {
      :id => self.id,
      :group_id => self.group_id,
      :user => user.basic_user_info_hash,
    }
    hash
  end
end