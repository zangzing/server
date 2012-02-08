class GroupsController < ApplicationController

  # shared code for album update and creation that
  # throws a friendly error message from the exception or error
  # If it gets an exception it doesn't understand it simply
  # returns that exception
  def handle_create_update_error(ex, name = nil)
    if ex.is_a?(ActiveRecord::RecordNotUnique)
      msg = "The group #{name} already exists"
      logger.error("#{msg} due to #{ex.message}")
      raise ZZAPIError.new(msg)
    elsif ex.is_a?(Exception)
      msg = "Unable to create the group #{name}"
      logger.error("#{msg} due to #{ex.message}")
      raise ZZAPIError.new(msg)
    elsif ex.is_a?(ActiveModel::Errors)
      ZZAPIError.new(ex)
    else
      ex
    end
  end

  # Creates a group for the current user.
  #
  # This is called as (POST):
  #
  # /zz_api/groups/create
  #
  # Executed in the context of the current signed in user
  #
  # You cannot have an @ in the group name.
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
      begin
        fields = filter_params(params, [:name])
        fields[:user_id] = current_user.id
        group = Group.new(fields)
        unless group.save
          raise ZZAPIError.new(group.errors)
        end
        group.as_hash
      rescue ActiveRecord::RecordNotUnique => ex
        msg = "The group #{fields[:name]} already exists"
        logger.error("#{msg} due to #{ex.message}")
        raise ZZAPIError.new(msg)
      rescue Exception => ex
        msg = "Unable to create the group #{fields[:name]}"
        logger.error("#{msg} due to #{ex.message}")
        raise ZZAPIError.new(msg)
      end
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
  # You cannot have an @ in the group name.
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
      begin
        fields = filter_params(params, [:name])
        fields[:user_id] = current_user.id
        unless @group.update_attributes(fields)
          raise ZZAPIError.new(@group.errors)
        end
        @group.as_hash
      rescue ActiveRecord::RecordNotUnique => ex
        msg = "The group #{fields[:name]} already exists"
        logger.error("#{msg} due to #{ex.message}")
        raise ZZAPIError.new(msg)
      rescue Exception => ex
        msg = "Unable to update the group #{fields[:name]}"
        logger.error("#{msg} due to #{ex.message}")
        raise ZZAPIError.new(msg)
      end
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
  #    :user => {                 --- Only exists when we have a wrapped user
  #        :id => users id,
  #        :my_group_id => the group that wraps just this user,
  #        :username => user name,
  #        :profile_photo_url => the url to the profile photo, nil if none,
  #        :first_name => first_name,
  #        :last_name => last_name,
  #        :email => email for this user (this will only be present for automatic users and in cases where you looked up the user via email)
  #        :automatic => true if an automatic user (one that has not created an account)
  #        :auto_by_contact => true if automatic user and was created simply by referencing (i.e. we added automatic as result of group or permission operation)
  #                            if automatic is set and this is false it means we have a user that has actually sent a photo in on that address
  #    }
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
  # We support the notion of hidden groups, which are any that have a first
  # character of .  When we see the . we filter those out of the list.
  #
  # [
  #   hash of group - see zz_api_info
  # ...
  # ]
  def zz_api_users_groups
    return unless require_user

    zz_api do
      # only accept those not wrapped and not beginning with .
      groups = Group.where("user_id = ? AND wrapped_user_id IS NULL AND name NOT LIKE '.%'", current_user.id).all
      Group.as_sorted_array(groups)
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
      GroupMember.as_array(fetch_group_members(@group), nil)
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
  # Errors:
  # If we have a list validation error with either the emails, user_ids, or user_names we collect the items that were
  # in error into a list for each type and raise an exception. The exception will be returned to the client
  # as json in the standard error format.  The code will be INVALID_LIST_ARGS (1001) and the
  # message part of the error will contain:
  #
  # {
  #   :emails => [
  #     {
  #       :index => the index in the corresponding input list location,
  #       :token => the invalid email,
  #       :error => an error string
  #     }
  #     ...
  #   ],
  #   :user_ids => [
  #     {
  #       :index => the index in the corresponding input list location,
  #       :token => the missing user_id,
  #       :error => an error string, may be blank
  #     }
  #     ...
  #   ],
  #   :user_names => [
  #     {
  #       :index => the index in the corresponding input list location,
  #       :token => the missing user name,
  #       :error => an error string, may be blank
  #     }
  #     ...
  #   ]
  # }
  def zz_api_add_members
    return unless require_user && require_owned_group

    zz_api do
      # build up list of each type and validate them
      group_id = @group.id
      user_ids, user_id_errors = User.validate_user_ids(params[:user_ids])
      ids_by_name, user_name_errors = User.validate_user_names(params[:user_names])
      user_ids += ids_by_name
      emails, email_errors, addresses = ZZ::EmailValidator.validate_email_list(params[:emails])

      # raise an error if any of the items passed were invalid
      unless email_errors.empty? && user_name_errors.empty? && user_id_errors.empty?
        # at least one error so raise exception
        raise ZZAPIInvalidListError.new({:user_ids => user_id_errors, :user_names => user_name_errors, :emails => email_errors})
      end

      converted_users, user_id_to_email = User.convert_to_users(addresses, current_user)
      converted_ids = converted_users.map(&:id)
      user_ids += converted_ids

      # ok now the user_ids array contains all members in user_id form so do the
      # bulk update
      rows = []
      user_ids.uniq!
      user_ids.each do |user_id|
        rows << [group_id, user_id]
      end

      if true
        # no notify support
        GroupMember.fast_update_members(rows)
      else
        # NOTE: this code has not been tested, it was put here to support notifying
        # albums that the membership of an InviteActivity has changed which we decided
        # not to do since we are dropping InviteActivites.  However this might
        # prove to be useful in the future so I am keeping the basic mechanisms
        # in place.  Just remember this has not been tested so will probably require
        # some work to ensure that it operates as expected...
        #
        # First determine which acls are tied to this group and what the role is
        # Then determine the current role of the users we are about to add
        # for those acls.
        # Then, make the change to membership, recheck the role of those users
        # for those acls.  If the user now has the role we notify the acls.
        resource_ids = ACL.all_resource_ids_for_group(group_id)
        before_acls = ACL.all_acls_for_users_in_resources(user_ids, resource_ids)

        GroupMember.fast_update_members(rows)

        after_acls = ACL.all_acls_for_users_in_resources(user_ids, resource_ids)

        # now figure out which users have had changes for a given acl
        changed_acls = after_acls - before_acls
        # and send out the notification to the acl manager
        ACLManager.group_additions(group_id, changed_acls)
      end

      # now fetch them all and return
      GroupMember.as_array(fetch_group_members(@group), user_id_to_email)
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
      GroupMember.as_array(fetch_group_members(@group), nil)
    end
  end

private
  # sort the members of a groups, because
  # the fields vary we sort by precedence of
  # if automatic user, just the email is used
  # if normal user, we sort on combined name field
  def sort_group_members(members)
    members = members.sort do |a,b|
      a_name = a.user.name_sort_value
      b_name = b.user.name_sort_value
      a_name.casecmp(b_name)
    end
    members
  end

  # fetch all the members in the group, do a deep set
  # of sql queries all the way down to the cover photos
  # to minimize the db calls needed
  def fetch_group_members(group)
    members = group.group_members.includes(:user => :profile_album).all
    albums = []
    members.each do |member|
      albums << member.user.profile_album
    end
    Album.fetch_bulk_covers(albums)
    # ok, we are pre-flighted with everything we need loaded now
    sort_group_members(members)
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

end
