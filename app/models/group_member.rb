class GroupMember < ActiveRecord::Base
  extend ZZActiveRecordUtils

  attr_accessible  :group_id, :user_id, :email_id

  belongs_to :user
  belongs_to :group

  # perform a bulk insert/update of group members
  # takes rows in the form
  # [ [group_id, user_id], ... ]
  # does an update on all of the rows specified in
  # a minimal number of queries
  def self.update_members(rows, notify = true)
    base_cmd = "INSERT INTO #{quoted_table_name}(group_id, user_id) VALUES "
    end_cmd = "ON DUPLICATE KEY UPDATE user_id = VALUES(user_id)"
    RawDB.fast_insert(connection, rows, base_cmd, end_cmd)
    notify_cache(rows) if notify
  end

  # perform a bulk delete of group members
  # takes rows in the form
  # [ [group_id, user_id], ... ]
  # does an update on all of the rows specified in
  # a minimal number of queries
  def self.remove_members(rows, notify = true)
    RawDB.fast_delete(connection, rows, ['group_id','user_id'], quoted_table_name)
    notify_cache(rows) if notify
  end

  # takes rows in the form
  # [ [group_id, user_id], ... ]
  # and notifies the cache manager of an acl
  # change for the given users
  def self.notify_cache(rows)
    affected_user_ids = rows.map {|r| r[1]}.uniq

    # technically we should split the fetch by type and only
    # do this for the Album type but this approach reduces
    # the queries and overhead at the cost of possibly invalidating
    # more items than need be
    Cache::Album::Manager.shared.user_albums_acl_modified(affected_user_ids)
  end

  # returns an array of hashes given an array of members
  def self.as_array(members, user_id_to_email)
    result = []
    members.each do |member|
      result << member.as_hash(user_id_to_email)
    end
    result
  end

  # returns a single member in hash form
  def as_hash(user_id_to_email)
    hash = {
      :group_id => self.group_id,
      :user => user.basic_user_info_hash(user_id_to_email),
    }
    hash
  end
end