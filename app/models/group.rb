class Group < ActiveRecord::Base
  extend ZZActiveRecordUtils

  attr_accessible  :user_id, :name, :wrapped_user_id

  has_many :group_members
  belongs_to :wrapped_user,             :class_name => 'User', :foreign_key => 'wrapped_user_id'
  belongs_to :user

  validates_each  :name do |record, attr, value|
    record.errors.add attr, 'must not have @' if value.match(/@/)
  end

  # destroy a single group, deleting any dependencies and notifying the cache manager
  def destroy
    Group.delete_groups_and_acls([id])
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

  # validate all the group names, returns an array
  # of found group_ids and a set of found names
  def self.convert_group_names(user_id, names)
    groups = Group.where('(user_id = ? OR wrapped_user_id IS NOT NULL) AND name IN (?)', user_id, names).all
    found_names = Set.new(groups.map {|g| g.name.downcase})
    group_ids = groups.map(&:id)
    return group_ids, found_names
  end

  # check for valid emails or group names, and
  # convert the group names to group_ids
  # returns
  # emails, errors, addresses, group_ids
  def self.filter_groups_and_emails(user_id, names)
    group_names = []
    names.each do |item|
      group_names << item if item.index('@').nil?
    end
    group_ids, found_groups = convert_group_names(user_id, group_names)
    emails, errors, addresses = ZZ::EmailValidator.validate_email_list(names)
    filtered_errs = []
    if errors.length > 0
      # could be groups, check them
      errors.each do |err|
        name = err[:token].downcase
        filtered_errs << err unless found_groups.include?(name)
      end
    end
    return emails, filtered_errs, addresses, group_ids
  end

  # given a user, verify that the group_ids passed
  # are valid for that user (allows wrapped groups owned by anyone)
  # returns as array of valid group_ids
  def self.allowed_group_ids(user_id, group_ids)
    groups = Group.where('(user_id = ? OR wrapped_user_id IS NOT NULL) AND id IN (?)', user_id, group_ids).all
    group_ids = groups.map(&:id)
  end

  # given an array of group_ids, return all the
  # users_ids, low level call for speed
  def self.users_in_groups(group_ids)
    return [] if group_ids.empty?
    in_clause = RawDB.build_in_clause(connection, group_ids)
    sql = "SELECT DISTINCT gm.user_id FROM group_members gm, groups g WHERE gm.group_id = g.id AND g.id IN #{in_clause}"
    RawDB.single_values(connection.execute(sql))
  end

  # given an array of group_ids, return all the
  # users emails as lower case, low level call for speed
  def self.emails_in_groups(group_ids)
    return [] if group_ids.empty?
    in_clause = RawDB.build_in_clause(connection, group_ids)
    sql = "SELECT DISTINCT LOWER(u.email) FROM users u, group_members gm, groups g WHERE gm.group_id = g.id AND gm.user_id = u.id AND g.id IN #{in_clause}"
    RawDB.single_values(connection.execute(sql))
  end

  # take the recipients email list which contains
  # individual emails and possibly group_ids
  # and flatten into a single set of emails
  # filters out duplicates
  def self.flatten_emails(recipients)
    combined_list = Set.new
    group_ids = []
    recipients.each do |email|
      group_id = Integer(email) rescue false
      if group_id
        # was a group_id, so add to group_ids list
        group_ids << group_id
      else
        combined_list << email.downcase
      end
    end
    if group_ids.empty? == false
      # we have group_ids, flatten them into a list of emails
      combined_list += Group.emails_in_groups(group_ids)
    end
    combined_list
  end

  # delete the groups and group members for the given group ids
  def self.delete_groups(group_ids)
    # delete the group members related to this group
    GroupMember.delete_all(:group_id => group_ids)
    # and now the groups
    Group.delete(group_ids)
  end

  # deletes all the given groups and also any associated ACLs
  def self.delete_groups_and_acls(group_ids)
    # convert to the form that the ACL api wants for removing all groups
    rows = []
    group_ids.each do |group_id|
      rows << [group_id]
    end

    # remove all acls for the given groups
    affected_user_ids = ACL.remove_groups_for_any_type(rows)

    # now remove the groups and members
    self.delete_groups(group_ids)

    # technically we should split the fetch by type and only
    # do this for the Album type but this approach reduces
    # the queries and overhead at the cost of possibly invalidating
    # more items than need be
    Cache::Album::Manager.shared.user_albums_acl_modified(affected_user_ids)
  end

  # returns an array of group ids for the
  # given user, low level call for speed
  def self.groups_for_user(user_id)
    sql = "SELECT id FROM groups WHERE user_id = #{q(user_id)}"
    RawDB.single_values(connection.execute(sql))
  end

  def self.name_sort_value(group)
    return group.name if group.wrapped_user_id.nil?
    # a wrapped user, so use users name
    group.wrapped_user.name_sort_value
  end

  def self.sort(groups)
    groups = groups.sort do |a,b|
      a_name = name_sort_value(a)
      b_name = name_sort_value(b)
      a_name.casecmp(b_name)
    end
  end

  # sorted form of as_array
  def self.as_sorted_array(groups, add_ins = {})
    groups = sort(groups)
    as_array(groups, add_ins)
  end

  # return an array of groups
  # also lumps in with each item the options in add_ins
  def self.as_array(groups, add_ins = {})
    result = []
    groups.each do |group|
      result << group.as_hash(add_ins)
    end
    result
  end

  # return a single group as a hash
  def as_hash(add_ins = {})
    hash = {
        :id => self.id,
        :name => self.name,
        :user_id => self.user_id,
        :wrapped_user_id => self.wrapped_user_id,
    }
    hash = hash.merge(add_ins)
    # if a wrapped user, add in user related info
    hash[:user] = wrapped_user.basic_user_info_hash if self.wrapped_user_id
    hash
  end

end