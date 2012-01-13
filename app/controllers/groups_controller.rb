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
  # Returns the group info
  #
  # {
  #   :id => the group id
  #   :user_id => the owning user
  #   :name => the name
  #   :self_group => true if special group representing the owning user
  # }
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
  # Returns the group info
  #
  # {
  #   :id => the group id
  #   :user_id => the owning user
  #   :name => the name
  #   :self_group => true if special group representing the owning user
  # }
  def zz_api_update
    return unless require_user && require_owned_group

    zz_api do
      fields = filter_params(params, [:name])
      @group.update_attributes(fields)
      unless group.save
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
  # Executed in the context of the current signed in user
  #
  # Input:
  #
  # Returns the group info
  #
  # {
  #   :id => the group id
  #   :user_id => the owning user
  #   :name => the name
  #   :self_group => true if special group representing the owning user
  # }
  def zz_api_info
    return unless require_user && require_owned_group

    zz_api do
      @group.as_hash
    end
  end

  # Gets or creates the user self group for the
  # specified user
  #
  # This is called as (GET):
  #
  # /zz_api/groups/wrap_user
  #
  # Executed in the context of the current signed in user
  #
  # Input:
  # {
  #     :email => set if adding by email
  #     :user_id => set if adding by user_id
  # }
  #
  #
  # Returns the group info
  #
  # {
  #   :id => the group id
  #   :user_id => the owning user
  #   :name => the name
  #   :self_group => true representing a special single user group - in a UI only the user info should be shown
  #   :member_info {
  #      :group_id => group we belong to,
  #      :user => {
  #          :id => users id,
  #          :username => user name,
  #          :email => [
  #            {
  #                :id => Id of this email for user,
  #                :email => users email
  #            }
  #          ],
  #          :first_name => first_name,
  #          :last_name => last_name,
  #          :automatic => true if an automatic user (one that has not created an account)
  #      },
  #      :email_id => the email id to show or nil,
  #   }
  # }
  def zz_api_wrap_user
    return unless require_user
    zz_api do
      user = nil
      user_id = params[:user_id]
      email = params[:email]

      # find the user
      if user_id
        user = User.find(user_id)
      elsif email
        email = Share.validate_email(email)
        user = User.find_by_email(email)
      end
      raise ArgumentError.new("User not found by email or user_id") if user.nil?

      # find or create the group and update email
      group = find_or_create_wrapped_user(current_user.id, user.id, email)
      result = group.as_hash
      result[:member_info] = group.group_members.first.as_hash
      result
    end
  end

  # Get the current members of the group.
  #
  # This is called as (GET):
  #
  # /zz_api/groups/:group_id
  #
  # Executed in the context of the current signed in user
  #
  #
  # Returns:
  #
  # [
  # {
  #  :group_id => group we belong to,
  #  :user => {
  #      :id => users id,
  #      :username => user name,
  #      :email => [
  #        {
  #            :id => Id of this email for user,
  #            :email => users email
  #        }
  #      ],
  #      :first_name => first_name,
  #      :last_name => last_name,
  #      :automatic => true if an automatic user (one that has not created an account)
  #  },
  #  :email_id => the email id to show or nil,
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

  # fetch all the members in the group
  def fetch_group_members(group)
    members = group.group_members
  end

  # Add or update members in the group.
  #
  # This is called as (PUT):
  #
  # /zz_api/groups/:group_id/update_members
  #
  # Executed in the context of the current signed in user
  #
  # Input:
  # {
  #   :users => [
  #   {
  #     :email => set if adding by email
  #     :user_id => set if adding by user_id
  #     :email_id => set if tied to specific email
  #   }
  #   ...
  #   ]
  # }
  #
  #
  # Returns:
  # fetches and returns all members as in members call
  #
  def zz_api_update_members
    return unless require_user && require_owned_group

    zz_api do
      # build up list of each type and validate them
      group_id = @group.id
      emails, user_ids = validate_members(params[:users])
      user_ids += convert_to_users(emails)
      # ok now the user_ids array contains all members in user_id form so do the
      # bulk update
      rows = []
      user_ids.each do |member|
        rows << [group_id, member[:user_id], member[:email_id]]
      end
      GroupMember.fast_update_members(rows)

      # now fetch them all and return
      GroupMember.as_array(fetch_group_members(@group))
    end
  end

  # Add or update members in the group.
  #
  # This is called as (PUT):
  #
  # /zz_api/groups/:group_id/remove_members
  #
  # Executed in the context of the current signed in user
  #
  # Input:
  # {
  #   :users => [
  #   {
  #     :email => set if adding by email
  #     :user_id => set if adding by user_id
  #   }
  #   ...
  #   ]
  # }
  #
  #
  # Returns:
  # fetches and returns all members as in members call
  #
  def zz_api_remove_members
    return unless require_user && require_owned_group

    zz_api do
      # build up a list of user_ids
      user_ids = array_of_non_nil(members, :user_id)

      # extracting user_ids from emails given
      emails = array_of_non_nil(members, :email)
      if emails.empty? == false
        user_by_email = User.select("id").where(:email => emails)

        # now combine into a single list of user ids
        user_ids += user_by_email.map(&:id) if user_by_email
      end

      # and delete them
      @group.delete(user_ids)

      # now fetch them all and return
      GroupMember.as_array(fetch_group_members(@group))
    end
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
  def convert_to_users(members)
    # first find the ones that map to a user
    emails = array_of_non_nil(members, :email)
    found_users = User.select("id,email").where(:email => emails)
    # create a map from email to user_id
    email_to_user_id = {}
    found_users.each {|user| email_to_user_id[user.email] = user.id }

    # ok, now walk the members to find out which ones need new user created
    emails.each do |member|
      email = member[:email]
      user_id = email_to_user_id[email]
      if user_id
        member[:user_id] = user_id
      else
        # not found, so make an automatic user
        user = User.create_automatic(email)
        member[:user_id] = user.id
      end
    end
  end

  # takes an array of members in the input form from the add_members call and
  # validates all items.  If any items do not validate we fail and raise an
  # exception
  #
  # returns results set up by email referenced and user_id referenced
  # all users_ids must exist or we fail.  Any emails that map to
  # valid users will be converted to user_ids type add
  #
  # [emails, user_ids]
  #
  def validate_members(members)
    user_ids = []
    emails = []
    members.each do |member|
      email = member[:email]
      if email
        email = Share.validate_email(email)
        member[:email] = email  # put back validated form
        member[:user_id] = nil
        emails << member
      else
        user_id = member[:user_id]
        if user_id
          user_ids << member  # will be checked in bulk
        end
      end
    end
    # now make sure all the ones using user_id exist
    ids = array_of_non_nil(user_ids, :user_id)
    raise ArgumentError.new("Duplicate user_ids were found") unless ids.length == ids.uniq.length
    users = User.select("id").where(:id => ids)
    found_ids = Set.new(users.map(&:id))
    ids.each do |id|
      raise ArgumentError.new("Invalid user_id specified: #{id}") unless found_ids.include?(id)
    end
    # TODO: make sure if they are setting the email_id pref that we match them all to the given user

    [emails, user_ids]
  end
end
