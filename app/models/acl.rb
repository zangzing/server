class ACL < ActiveRecord::Base
  extend ZZActiveRecordUtils

  # update the group roles
  # by adding or modifying existing group roles
  # for a given resource_id
  # takes an array of rows to update
  # [[resource_id, type, group_id, role]..]
  # returns an array of user_ids that were affected
  def self.update_groups(rows)
    base_cmd = "INSERT INTO #{quoted_table_name}(resource_id, type, group_id, role) VALUES "
    end_cmd = "ON DUPLICATE KEY UPDATE role = VALUES(role)"
    RawDB.fast_insert(connection, rows, base_cmd, end_cmd)
    affected_users(rows)
  end

  # remove a set of groups from a list of resources and types
  # the rows follow the form of
  # [[resource_id, type, group_id]..]
  # returns an array of user_ids that were affected
  def self.remove_groups(rows)
    RawDB.fast_delete(connection, rows, ['resource_id','type','group_id'], quoted_table_name)
    affected_users(rows)
  end

  # remove a set of groups and types
  # the rows follow the form of
  # [[type, group_id]..]
  # returns an array of user_ids that were affected
  def self.remove_groups_for_any_resource(rows)
    RawDB.fast_delete(connection, rows, ['type','group_id'], quoted_table_name)
    affected_users(rows, 1)   # group_ids are at offset 1
  end

  # remove a set of groups for any type
  # the rows follow the form of
  # [[group_id]..]
  # returns an array of user_ids that were affected
  def self.remove_groups_for_any_type(rows)
    RawDB.fast_delete(connection, rows, ['group_id'], quoted_table_name)
    affected_users(rows, 0)   # group_ids are at offset 0
  end

  # delete numerous acls
  # the rows follow the form of
  # [[resource_id, type]...]
  # returns an array of user_ids that were affected
  def self.delete_acls(rows)
    return [] if rows.empty?
    # find all of the users impacted
    base_cmd = "SELECT DISTINCT gm.user_id FROM group_members gm, acls a WHERE gm.group_id = a.group_id AND "
    user_ids = RawDB.single_values(RawDB.fast_multi_execute(connection, rows, ['a.resource_id','a.type'], base_cmd))
    # now delete all the acls referenced
    RawDB.fast_delete(connection, rows, ['resource_id','type'], quoted_table_name)
    user_ids.uniq
  end

  # return the role for a user in a given acl
  # returns min role for all groups user belongs to
  # the lower the role number the higher the privs
  # or nil if no role
  def self.role_for_user(user_id, resource_id, type)
    sql = "SELECT MIN(a.role) FROM acls a, group_members gm WHERE gm.group_id = a.group_id AND
                a.resource_id = #{q(resource_id)} AND a.type = #{q(type)} AND gm.user_id = #{q(user_id)}"
    RawDB.single_value(RawDB.execute(connection, sql))
  end

  # return the role for a group in a given acl
  # returns min role for all groups user belongs to
  # or nil if no role
  def self.role_for_group(group_id, resource_id, type)
    sql = "SELECT MIN(a.role) FROM acls a, group_members gm WHERE gm.group_id = a.group_id AND
                a.resource_id = #{q(resource_id)} AND a.type = #{q(type)} AND gm.group_id = #{q(group_id)}"
    RawDB.single_value(RawDB.execute(connection, sql))
  end

  # return all the users that match a given role for a single resource
  # returns an array of
  # [[user_id, role], ...]
  def self.users_with_role(resource_id, type, first = 0, last = 10000)
    sql = "SELECT gm.user_id, MIN(a.role) FROM acls a, group_members gm WHERE gm.group_id = a.group_id AND
                (a.role >= #{q(first)} AND a.role <= #{q(last)}) AND a.type = #{q(type)} AND a.resource_id = #{q(resource_id)} group by gm.user_id"
    RawDB.as_rows(RawDB.execute(connection, sql))
  end

  # return all the groups that match a given role for a single resource
  # returns an array of
  # [[group_id, role], ...]
  def self.groups_with_role(resource_id, type, first = 0, last = 10000)
    sql = "SELECT a.group_id, a.role FROM acls a, group_members gm WHERE gm.group_id = a.group_id AND
                (a.role >= #{q(first)} AND a.role <= #{q(last)}) AND a.type = #{q(type)} AND a.resource_id = #{q(resource_id)} group by a.group_id"
    RawDB.as_rows(RawDB.execute(connection, sql))
  end

  # return all the acls of the given type for a user
  # and the role for each
  # first and last represent the role range to return
  # returned as
  # [[resource_id, role]...]
  def self.acls_for_user(user_id, type, first = 0, last = 10000)
    sql = "SELECT a.resource_id, MIN(a.role) FROM acls a, group_members gm WHERE gm.group_id = a.group_id AND
                (a.role >= #{q(first)} AND a.role <= #{q(last)}) AND a.type = #{q(type)} AND gm.user_id = #{q(user_id)} group by a.resource_id"
    RawDB.as_rows(RawDB.execute(connection, sql))
  end

  # return all the users, and acl info for a set of user_ids and resource_ids
  # first and last represent the role range to return
  # returned as
  # [[user_id, type, resource_id, role]...]
  def self.all_acls_for_users_in_resources(user_ids, resource_ids, first = 0, last = 10000)
    return [] if user_ids.empty? || resource_ids.empty?
    sql = "SELECT gm.user_id, a.type, a.resource_id, MIN(a.role) FROM acls a, group_members gm WHERE gm.group_id = a.group_id AND
                (a.role >= #{q(first)} AND a.role <= #{q(last)}) AND gm.user_id IN #{RawDB.build_in_clause(connection, user_ids)} AND
                a.resource_id IN #{RawDB.build_in_clause(connection, resource_ids)} group by gm.user_id, a.type, a.resource_id"
    RawDB.as_rows(RawDB.execute(connection, sql))
  end

  # return all the acls of the given type for a group
  # and the role for each
  # first and last represent the role range to return
  # returned as
  # [[resource_id, role]...]
  def self.acls_for_group(group_id, type, first = 0, last = 10000)
    sql = "SELECT a.resource_id, MIN(a.role) FROM acls a, group_members gm WHERE gm.group_id = a.group_id AND
                (a.role >= #{q(first)} AND a.role <= #{q(last)}) AND a.type = #{q(type)} AND gm.group_id = #{q(group_id)} group by a.resource_id"
    RawDB.as_rows(RawDB.execute(connection, sql))
  end

  # return just resource_ids, don't care about type
  # since this query feed into another query where type is
  # determined.
  # and the role for each
  # first and last represent the role range to return
  # returned as
  # [resource_id, ...]
  def self.all_resource_ids_for_group(group_id, first = 0, last = 10000)
    sql = "SELECT DISTINCT resource_id FROM acls WHERE
                (role >= #{q(first)} AND role <= #{q(last)}) AND group_id = #{q(group_id)}"
    RawDB.single_values(RawDB.execute(connection, sql))
  end


def self.test(count)
  rows = []
  acls = []
  count.times do |i|
    rows << [i, 'Album', 2, 100]
    acls << [i, 'Album']
  end
  update_groups(rows)

#  delete_acls(acls)
  #delete_groups(rows)
end

  # takes data in the form passed to update_groups
  # and returns a array of user_ids
  def self.affected_users(rows, offset = 2)
    group_ids = rows.map {|row| row[offset]}
    user_ids = Group.users_in_groups(group_ids)
  end

  # return a single group as a hash
  def as_hash
    hash = {
    }
    hash
  end

end
