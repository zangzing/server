class ACLManager
  # return the type tracker which can be used
  # to enumerate the types registered
  def self.type_tracker
    @@type_tracker ||= Set.new()
  end

  # each type of ACL should register here
  # this is so we know which types exist on delete
  # operations for users
  def self.register_type type
    type_tracker.add(type)
  end
end