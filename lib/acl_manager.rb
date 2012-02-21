class ACLManager
  # return the type tracker which can be used
  # to enumerate the types registered
  def self.type_tracker
    @@type_tracker ||= {}
  end

  # each type of ACL should register here
  # with its group handler.  The group handler
  # will be called when additions to the group occur.
  def self.register_type(type, group_handler)
    type_tracker[type] = group_handler
  end

  def self.get_or_make(hash, key)
    hash[key] = {} if hash[key].nil?
    hash[key]
  end

  # the group has been modified (we only track additions here)
  # so find the acls for each modification and notify them
  # the list comes into us in this form
  # [[user_id, type, resource_id, role]...]
  def self.group_additions(group_id, user_roles)
    hash = {}
    # organize by type, and then by resource_id
    user_roles.each do |role|
      user_id = role[0]
      type = role[1]
      resource_id = role[2]
      acl_role = role[3]

      # now store them hierarchically
      by_type = get_or_make(hash, type)
      by_resource_id = get_or_make(by_type, resource_id)
      by_resource_id[user_id] = acl_role
    end

    # ok, now we are grouped by type at the top, resource within, and then user_id=>role
    hash.each_pair do |type, by_resource_id|
      handler = type_tracker[type]
      next if handler.nil?
      by_resource_id.each_pair do |resource_id, by_user_id|
        # gather the list of user ids and make call to handler
        user_ids = by_user_id.keys
#        puts "g: #{group_id}, r: #{resource_id}, u: #{user_ids.join(',')}"
        handler.added_members(group_id, resource_id, user_ids)
      end
    end
  end
end