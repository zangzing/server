class GroupsController < ApplicationController

  # Creates a group for the current user.
  #
  # This is called as (POST):
  #
  # /zz_api/groups/create
  #
  # Executed in the context of the current signed in user
  #
  # Input:
  #
  # {
  #   :name => the name of the group
  # }
  #
  #
  # Returns the group info - see zz_api_info
  #
  def zz_api_create
    return unless require_user

    zz_api do
      fields = filter_params(params, [:name])
      fields[:user_id] = current_user.id
      group = Group.new(fields)
      unless group.save
        raise ZZAPIError.new(group.errors)
      end
      group.as_hash
    end
  end

  # Updates the group for the current user.
  #
  # This is called as (PUT):
  #
  # /zz_api/groups/:group_id
  #
  # Executed in the context of the current signed in user
  #
  # Input:
  #
  # {
  #   :name => the new name
  # }
  #
  #
  # Returns the group info - see zz_api_info
  #
  def zz_api_update
    return unless require_user && require_owned_group

    zz_api do
      fields = filter_params(params, [:name])

      unless @group.update_attributes(fields)
        raise ZZAPIError.new(group.errors)
      end
      @group.as_hash
    end
  end

  # Destroys a group for the current user.
  #
  # This is called as (DELETE):
  #
  # /zz_api/groups/:group_id
  #
  # Executed in the context of the current signed in user
  #
  #
  # Returns nothing
  #
  def zz_api_destroy
    return unless require_user && require_owned_group

    zz_api do
      @group.destroy
      nil
    end
  end

  # Gets info about the group.
  #
  # This is called as (GET):
  #
  # /zz_api/groups/:group_id
  #
  # Executed in the context of the current signed in user.
  #
  # Input:
  #
  # Returns the group info.  When the group is a wrapper around a single user
  # the user field will be present.  From this you can extract the user
  # related info.  For non wrapped groups the user field will be missing. You
  # can get detailed info about the users by calling zz_api_members
  #
  # {
  #    :id => the group id
  #    :user_id => the owning user
  #    :name => the name of the group
  #    :user => {
  #        :id => users id,
  #        :username => user name,
  #        :profile_photo_url => the url to the profile photo,
  #        :first_name => first_name,
  #        :last_name => last_name,
  #        :automatic => true if an automatic user (one that has not created an account)
  #    },
  # }
  def zz_api_info
    return unless require_user && require_owned_group

    zz_api do
      @group.as_hash
    end
  end

  # Gets all groups for a given user.
  #
  # This is called as (GET):
  #
  # /zz_api/users/groups/all
  #
  # Executed in the context of the current signed in user
  #
  # Input:
  #
  # Returns an array of all the users groups.  See zz_api_info for details.
  #
  # [
  #   hash of group - see zz_api_info
  # ...
  # ]
  def zz_api_users_groups
    return unless require_user

    zz_api do
      groups = Group.find_all_by_user_id(current_user.id)
      Group.as_array(groups)
    end
  end


  # Get the current members of the group.
  #
  # This is called as (GET):
  #
  # /zz_api/groups/:group_id/members
  #
  # Executed in the context of the current signed in user
  #
  #
  # Returns:
  #
  # [
  # {
  #  :group_id => group we belong to,
  #  :user => see user portion of info returned from zz_api_info
  # }
  # ...
  # ]
  #
  def zz_api_members
    return unless require_user && require_owned_group

    zz_api do
      GroupMember.as_array(fetch_group_members(@group))
    end
  end

  # Adds members in the group.  Will create automatic users
  # for emails that do not map to a current user.
  #
  # This is called as (POST):
  #
  # /zz_api/groups/:group_id/add_members
  #
  # Executed in the context of the current signed in user
  #
  # Input:
  # {
  #   :user_ids => [ array of user ids to add ],
  #   :user_names => [ array of user names to add ],
  #   :emails => [ array of emails to add ],
  # }
  #
  #
  # Returns:
  # fetches and returns all members as in members call
  #
  def zz_api_add_members
    return unless require_user && require_owned_group

    zz_api do
      # build up list of each type and validate them
      group_id = @group.id
      user_ids = []
      user_ids += validate_user_ids(params[:user_ids])
      user_ids += validate_user_names(params[:user_names])
      addresses = validate_emails(params[:emails])
      user_ids += convert_to_users(addresses)

      # ok now the user_ids array contains all members in user_id form so do the
      # bulk update
      rows = []
      user_ids.each do |user_id|
        rows << [group_id, user_id]
      end
      GroupMember.fast_update_members(rows)

      # now fetch them all and return
      GroupMember.as_array(fetch_group_members(@group))
    end
  end

  # Remove members from the group based on user_ids
  #
  # This is called as (DELETE):
  #
  # /zz_api/groups/:group_id/remove_members
  #
  # Executed in the context of the current signed in user
  #
  # Input:
  # {
  #   :user_ids => [
  #     user_id - the user id to delete
  #   ...
  #   ]
  # }
  #
  #
  # Returns:
  # fetches and returns all members as in get members call
  #
  def zz_api_remove_members
    return unless require_user && require_owned_group

    zz_api do
      # build up a list of user_ids
      user_ids = params[:user_ids]

      # and delete them
      GroupMember.where(:group_id => @group.id, :user_id => user_ids).delete_all

      # now fetch them all and return
      GroupMember.as_array(fetch_group_members(@group))
    end
  end

private
  # fetch all the members in the group
  def fetch_group_members(group)
    members = group.group_members.includes(:user)
  end

  # returns an array of non nil values for the symbol specified
  def array_of_non_nil(members, symbol)
    a = []
    members.each do |m|
      v = m[symbol]
      a << v if v
    end
    a
  end

  # for each member in the array, try to find an existing email to user id mapping
  # for those not found, create new automatic users
  # converts the members in place
  def convert_to_users(addresses)
    user_ids = []
    return user_ids if addresses.empty?

    # first find the ones that map to a user
    emails = addresses.map(&:address)
    found_users = User.select("id,email").where(:email => emails)
    # create a map from email to user_id
    email_to_user_id = {}
    found_users.each {|user| email_to_user_id[user.email] = user.id }

    # ok, now walk the members to find out which ones need new user created
    addresses.each do |address|
      email = address.address
      user_id = email_to_user_id[email]
      if user_id
        user_ids << user_id
      else
        # not found, so make an automatic user
        user = User.create_automatic(email, address.display_name)
        user_ids << user.id
      end
    end
    user_ids
  end

  # validates user ids
  # takes an array of user ids, if any are invalid, returns an error
  #
  def validate_user_ids(ids)
    user_ids = []
    if ids && ids.length > 0
      users = User.select("id").where(:id => ids)
      found_ids = Set.new(users.map(&:id))
      ids.each do |id|
        raise ArgumentError.new("Invalid user_id specified: #{id}") unless found_ids.include?(id)
      end
      user_ids = ids
    end
    user_ids
  end

  # validates user names
  # takes an array of user names, if any are invalid, returns an error
  #
  # returns array of user_ids
  #
  def validate_user_names(names)
    user_ids = []
    if names && names.length > 0
      users = User.select("id, username").where(:username => names)
      found_names = Set.new(users.map(&:username))
      names.each do |name|
        raise ArgumentError.new("Invalid username specified: #{name}") unless found_names.include?(name)
      end
      user_ids = users.map(&:id)
    end
    user_ids
  end

  # validates emails, just checks to see if they are in a valid email
  # format and returns them as address records
  #
  def validate_emails(emails)
    addresses = []
    if emails && emails.length > 0
      emails.each do |email|
        addresses << Share.validate_email(email)
      end
    end
    addresses
  end

end
