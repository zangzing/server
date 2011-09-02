class PeopleController < ApplicationController
  before_filter :require_album,             :only => [ :album_index ]
  before_filter :require_album_viewer_role, :only => [ :album_index ]

  # This is the people view for an album
  # @album is set by the require_album before_filter
  def album_index


    @contributors = []

    # collect all invited contributors
    @album.contributors.each do | id |
      user = User.find_by_id( id )
      if user
        @contributors << user
      end
    end

    # collect everone who has contributed
    # includes the case where non-"contributors" contribute to
    # open album
    @album.upload_batches.each do |batch|
      @contributors << batch.user
    end
    @contributors.uniq!


    # an array  of users that have not contributed photos yet
    @inactive_contributors = []

    # an array of the users who like this album
    @likers = @album.likers
    @photo_likers = @album.users_who_like_albums_photos
  end

  def user_index
    begin
      @user = User.find(params[:user_id])
      @user_is_auto_follow = User.auto_like_ids.include?( @user.id )
    rescue ActiveRecord::RecordNotFound => e
      user_not_found_redirect_to_homepage_or_potd
      return
    end
  end

private

  # To be run as a before_filter
  # sets @album
  def require_album
    begin
      @album = (params[:user_id] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.find( params[:album_id] ) )
    rescue ActiveRecord::RecordNotFound => e
      album_not_found_redirect_to_owners_homepage(params[:user_id])
      return
    end
  end


end

