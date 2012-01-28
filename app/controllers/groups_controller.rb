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
  #        :my_group_id => the group that wraps just this user,
  #        :username => user name,
  #        :profile_photo_url => the url to the profile photo, nil if none,
  #        :first_name => first_name,
  #        :last_name => last_name,
  #        :email => email for this user (this will only be present for automatic users and in cases where you looked up the user via email)
  #        :automatic => true if an automatic user (one that has not created an account)
  #        :auto_by_contact => true if automatic user and was created simply by referencing (i.e. we added automatic as result of group or permission operation)
  #                            if automatic is set and this is false it means we have a user that has actually sent a photo in on that address
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
      groups = Group.where('user_id = ? AND wrapped_user_id IS NULL', current_user.id).all
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
  def zz_api_add_members
    return unless require_user && require_owned_group

    zz_api do
      # build up list of each type and validate them
      group_id = @group.id
      user_ids = []
      user_ids += User.validate_user_ids(params[:user_ids])
      user_ids += User.validate_user_names(params[:user_names])
      addresses = User.validate_emails(params[:emails])
      converted_ids, user_id_to_email = User.convert_to_users(addresses)
      user_ids += converted_ids

      # ok now the user_ids array contains all members in user_id form so do the
      # bulk update
      rows = []
      user_ids.uniq!
      user_ids.each do |user_id|
        rows << [group_id, user_id]
      end
      GroupMember.fast_update_members(rows)

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
    members
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
