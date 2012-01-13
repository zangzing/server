class GroupMember < ActiveRecord::Base
  attr_accessible  :group_id, :user_id, :twitter, :facebook, :email_id

  has_many :users

  def self.max_insert_size
    @@safe_max_size ||= RawDB.safe_max_size(connection)
  end

  # perform a bulk insert/update of group members
  # takes rows in the form
  # [ [group_id, user_id, email_id], ... ]
  # does an update on all of the rows specified in
  # a minimal number of queries
  def self.fast_update_members(rows)
    db = connection
    base_cmd = "INSERT INTO #{quoted_table_name}(group_id, user_id, email_id) VALUES "
    end_cmd = "ON DUPLICATE KEY UPDATE email_id = VALUES(email_id)"
    RawDB.fast_insert(db, max_insert_size, rows, base_cmd, end_cmd)
  end

  # returns an array of hashes given an array of groups
  def self.as_array(groups)
    result = []
    groups.each do |group|
      result << group.as_hash
    end
    result
  end

  # returns a single group in hash form
  def as_hash
    user = self.user
    {
      :group_id => self.group_id,
      :user => {
          :id => user.id,
          :username => user.username,
          :email => [
            {
                :id => 0,
                :email => user.email
            }
          ],
          :first_name => user.first_name,
          :last_name => user.last_name,
          :automatic => user.automatic,
      },
      :email_id => self.email_id,
    }
  end
end