require 'cache/album/manager'

class Like < ActiveRecord::Base
  include PrettyUrlHelper

  attr_accessible :user_id, :subject_id, :subject_type

  belongs_to :user
  belongs_to :subject


  before_create :set_type
  after_commit  :post, :on => :create
  after_commit  :create_like_activity, :on => :create


  #Like Subject Types
  USER = 'U'
  ALBUM='A'
  PHOTO='P'

  include Rails.application.routes.url_helpers
  default_url_options[:host] = Server::Application.config.application_host

  def self.clean_type( subject_type )
    case subject_type
      when USER,  'user'  then USER
      when ALBUM, 'album' then ALBUM
      else
        PHOTO
    end
  end




  def self.add( user_id, subject_id, subject_type )

    return if user_id == subject_id # do not allow following self

    begin
      #Create Like record, increase the subject_ids like counter
      like = Like.create( :user_id      => user_id,
                          :subject_id   => subject_id,
                          :subject_type => subject_type )
      LikeCounter.increase( like.subject_id, like.subject_type )
      Cache::Album::Manager.shared.like_added(user_id, like)
      case subject_type
        when USER,  'user'  then
          ZZ::Async::Email.enqueue( :user_liked,  user_id, subject_id )

        when ALBUM, 'album' then
          album = Album.find(subject_id)
          notify_user_ids = album.viewers(false)
          notify_user_ids.reject!{ |id| id == user_id } # don't notify the user who does the like

          notify_user_ids.each do |notify_user_id|
              ZZ::Async::Email.enqueue( :album_liked, user_id, album.id, notify_user_id )
          end

        when PHOTO, 'photo' then
          photo = Photo.find_by_id( subject_id )

          notify_user_ids = photo.album.viewers(false)
          notify_user_ids << photo.user_id
          notify_user_ids.reject!{ |id| id == user_id } # don't notify the user who does the like
          notify_user_ids.uniq!

          notify_user_ids.each do |notify_user_id|
            ZZ::Async::Email.enqueue( :photo_liked, user_id, photo.id, notify_user_id )
          end

      end
      return like
    rescue  ActiveRecord::RecordNotUnique
      #Like Record already exists, nothing to do
    end
    nil
  end


  def self.find_by_album_id(album_id)
    Like.where(:subject_id => album_id, :subject_type => Like::ALBUM)
  end

  def self.find_by_photo_id(photo_id)
    Like.where(:subject_id => photo_id, :subject_type => Like::PHOTO)
  end


  def self.post( user_id, subject_id, subject_type, message=nil, tweet=false, facebook=false, dothis=false )

    # Save user preferences if needed
    if dothis
      user = User.find(  user_id )
      user.preferences.tweet_likes     = tweet
      user.preferences.facebook_likes  = facebook
      user.preferences.asktopost_likes = false
      user.preferences.save
    end

    # Instead of searching and failing to find a like, just create a new Like shell (not saved to DB, no ARcallbacks)
    # and use it to create a post then discard. Its faster since we have all the info we need.
    Like.new( :user_id=>user_id, :subject_id=>subject_id, :subject_type=>subject_type ).post( message, tweet, facebook)
  end

  def self.remove( user_id, subject_id, subject_type )
    #Find and remove like record, decrease the subject_id like counter
    like = Like.find_by_user_id_and_subject_id_and_subject_type( user_id, subject_id, subject_type)
    if like
      like.destroy
      LikeCounter.decrease( subject_id, subject_type )
      Cache::Album::Manager.shared.like_removed(user_id, like)
    end
  end

  # Given a subject id an type it produces a default like message
  # if the subject is not found it returns the default-message
  def  self.default_like_post_message( subject_id, subject_type )
    case subject_type
      when USER, 'user'
        liked_user = User.find( subject_id )
        return 'I am following '+liked_user.name+' on ZangZing - Group Photo Sharing'
      when ALBUM, 'album'
        liked_album = Album.find(subject_id )
        return 'I like '+liked_album.user.name+'\'s '+liked_album.name+' Album on ZangZing - Group Photo Sharing'
      when PHOTO, 'photo'
        liked_photo = Photo.find( subject_id )
        return 'I like '+liked_photo.user.name+'\'s Photo on ZangZing - Group Photo Sharing'
    end
    'I like ZangZing - Group Photo Sharing'
  end


  # Enqueues a facebook and/or twitter post for this like
  # If tweet is true or the like user set preferences.tweet_likes=true then tweet the like
  # If facebook is true or the like user set preferences.facebook_likes=true then facebook the like
  # Use the default message unless a custom message is provided
  def post( message = nil, tweet = false, facebook = false)
    begin
      user = User.find(user_id)
      message = Like.default_like_post_message( self.subject_id, self.subject_type ) unless message

      if ( tweet || ( !user.preferences.asktopost_likes && user.preferences.tweet_likes ) ) && user.identity_for_twitter.has_credentials?
          user.identity_for_twitter.post_like( self, message )
      end
      if  (facebook || ( !user.preferences.asktopost_likes && user.preferences.facebook_likes )) && user.identity_for_facebook.has_credentials?
         user.identity_for_facebook.post_like( self, message)
      end
    rescue ActiveRecord::RecordNotFound
      #user was not found, nothing to post
    end
  end

  # Returns the url to reach the like subject
  # if the subject is not found, it returns http://www.zangzing.com
  def url
    case subject_type
      when USER, 'user'
        user_pretty_url(  subject )
      when ALBUM, 'album'
        album_pretty_url( subject )
      when PHOTO, 'photo'
        photo_pretty_url( subject )
      else
        'http://www.zangzing.com'
    end
  end

  def subject
    return @subject if @subject
    case subject_type
      when USER, 'user'
          @subject = User.find( subject_id )
      when ALBUM, 'album'
          @subject = Album.find( subject_id )
      when PHOTO, 'photo'
          @subject = Photo.find( subject_id )
      else
        raise ActiveRecord::RecordNotFound.new().message = "Like subject_type #{subject_type} unknown"
    end
  end


  protected
  def create_like_activity
    @activity_subject = nil
    case self.subject_type
      when PHOTO
        @activity_subject = self.subject.album #boil photo activities to album
        @subject_owner = self.subject.user
      when ALBUM
        @activity_subject = self.subject
        @subject_owner = self.subject.user
      when USER
        @activity_subject = self.subject
        @subject_owner = self.subject
    end

    # Like activities are reciprocal:
    # - One activity is created for the subject so that it appears on the subject's activity list.
    # - Another is created for the subject_owner so that it appears in the subject owner's activities list.
    # Both activities point to the same like but we avoid having to do a triple join.
    # Albums/Photos fetch their activity list using the subject_id field
    # Users fetch their activity list by looking at the user_id field
    LikeActivity.create( :user => self.user, :subject => @activity_subject, :like => self )
    unless( self.user.id == @subject_owner.id )
      # do not create a reciprocal like activity for self likes.
      LikeActivity.create( :user => @subject_owner, :subject => @subject_owner, :like => self);
    end
  end

  def set_type
    self.subject_type = Like.clean_type( subject_type )       
  end
end