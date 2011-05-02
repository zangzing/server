require 'cache/album/manager'

class Like < ActiveRecord::Base
  include PrettyUrlHelper

  attr_accessible :user_id, :subject_id, :subject_type

  belongs_to :user
  belongs_to :subject


  before_create :set_type
  after_commit  :post, :on => :create

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
    begin
      #Create Like record, increase the subject_ids like counter
      like = Like.create( :user_id      => user_id,
                          :subject_id   => subject_id,
                          :subject_type => subject_type )
      LikeCounter.increase( like.subject_id, like.subject_type )
      Cache::Album::Manager.shared.like_added(user_id, like)
      case subject_type
        when USER,  'user'  then ZZ::Async::Email.enqueue( :user_liked,  user_id, subject_id )
        when ALBUM, 'album' then ZZ::Async::Email.enqueue( :album_liked, user_id, subject_id )
        when PHOTO, 'photo' then ZZ::Async::Email.enqueue( :photo_liked, user_id, subject_id )
      end
      return like
    rescue  ActiveRecord::RecordNotUnique
      #Like Record already exists, nothing to do
    end
    nil
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
        return 'I like '+liked_user.name+'\'s Photos on ZangZing - Group Photo Sharing'
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

      if ( tweet || ( !user.preferences.asktopost_likes && user.preferences.tweet_likes ) ) && user.identity_for_twitter.credentials_valid?
          user.identity_for_twitter.post_like( self, message )
      end
      if  (facebook || ( !user.preferences.asktopost_likes && user.preferences.facebook_likes )) && user.identity_for_facebook.credentials_valid?
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
        user_pretty_url(  User.find( subject_id ))
      when ALBUM, 'album'
        album_pretty_url( Album.find( subject_id ))
      when PHOTO, 'photo'
        photo_pretty_url( Photo.find( subject_id ))
      else
        'http://www.zangzing.com'
    end
  end


  protected
  def set_type
    self.subject_type = Like.clean_type( subject_type )       
  end
end