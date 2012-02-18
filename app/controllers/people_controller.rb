class PeopleController < ApplicationController
  before_filter :require_album,             :only => [ :album_index ]
  before_filter :require_album_viewer_role, :only => [ :album_index ]

  # This is the people view for an album
  # @album is set by the require_album before_filter
  def album_index


    @contributors = []

    # collect all invited contributors
    user_ids = @album.contributors
    @contributors = User.where(:id => user_ids).all

    # collect everone who has contributed
    # includes the case where non-"contributors" contribute to
    # open album
    @album.upload_batches.each do |batch|
      batch_user = batch.user
      @contributors << batch_user if batch_user
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
      @is_homepage_view = true
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
      if params[:user_id]
        @album = Album.safe_find(User.find(params[:user_id]), params[:album_id])
      else
        @album = Album.find(params[:album_id])
      end
    rescue ActiveRecord::RecordNotFound => e
      album_not_found_redirect_to_owners_homepage(params[:user_id])
      return
    end
  end


end

