class Like < ActiveRecord::Base
  attr_accessible :user_id, :subject_id, :subject_type


  before_create :set_type
  after_create  :post

  #Like Subject Types
  USER = 'U'
  ALBUM='A'
  PHOTO='P'

  class << self

    include Rails.application.routes.url_helpers

    def toggle( user_id, subject_id, subject_type )
      # Verify that the subject exists, (COMMENTED OUT FOR PERFORMANCE)
      #begin
      #  case subject_type
      #    when USER then  subject = User.find( subject_id )
      #    when ALBUM then subject = Album.find( subject_id )
      #    when PHOTO then subject = Photo.find( subject_id )
      #  end
      #rescue ActiveRecord::RecordNotFound
      #  # the subject does not exist, nothing to do.
      #  return false
      #end


      #if the user was not logged in when she liked the subject, there is nothing else to do
      if user_id.nil?
        #only increase the subject's like counter, no user logged in. Can't decrease 'Can't create Like Record
        LikeCounter.increase( subject_id)

      else
        begin
          Like.create( :user_id => user_id, :subject_id => subject_id, :subject_type => subject_type)
          #User Like Record created, increase the subject's like counter
          LikeCounter.increase( subject_id )
        rescue  ActiveRecord::RecordNotUnique
          #User Like Record exists, so lets turn it off and decrease the counter
          Like.find_by_user_id_and_subject_id( user_id, subject_id).destroy
          LikeCounter.decrease( subject_id )
        end
      end
      return
    end

    def post_with_preferences( user_id, subj_id, message=nil, tweet=false, facebook=false, dothis=false )
      if dothis
            user = User.find(  user_id )
            user.preferences.tweet_likes     = tweet
            user.preferences.facebook_likes  = facebook
            user.preferences.asktopost_likes = false
            user.preferences.save
      end
      like =  Like.find_by_user_id_and_subject_id( user_id, subj_id)
      if like
        like.post( message, tweet, facebook)
      end

    end

    def  default_like_post_message( user, subject_id, subject_type )
      @long_url = 'http://www.zangzing.com'
      @message   = 'I like ZangZing - Group Photo Sharing'

      default_url_options[:host] = Server::Application.config.application_host

      case subject_type
        when USER, 'user'
          @long_url = user_url(  subject_id )
          liked_user = User.find( subject_id )
          @message = 'I like '+liked_user.name+'\'s Photos on ZangZing - Group Photo Sharing'
        when ALBUM, 'album'
          @long_url = album_url( subject_id )
          liked_album = Album.find(subject_id )
          @message = 'I like '+liked_album.user.name+'\'s '+liked_album.name+
              ' Album on ZangZing - Group Photo Sharing'
        when PHOTO, 'photo'
          liked_photo = Photo.find( subject_id )
          @long_url = album_photos_url( liked_photo.album )+'/#!'+subject_id
          @message = 'I like '+liked_photo.user.name+'\'s Photo on ZangZing - Group Photo Sharing'
      end
      bitly = Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key])
      url = bitly.shorten( @long_url )

      return url, @message
    end
  end

  def post( message = nil, tweet = false, facebook = false)
    begin
      user = User.find(user_id)
      if  user.preferences.tweet_likes || tweet  ||   user.preferences.facebook_likes || facebook 

        bitly_url, default_message = Like.default_like_post_message( user, self.subject_id, self.subject_type )
        message = default_message unless message

        if ( user.preferences.tweet_likes || tweet ) && user.identity_for_twitter.credentials_valid?
          user.identity_for_twitter.post( bitly_url.short_url,  message)
        end
        if  (user.preferences.facebook_likes || facebook ) && user.identity_for_facebook.credentials_valid?
          user.identity_for_facebook.post( bitly_url.long_url , message)
        end
      end
    rescue ActiveRecord::RecordNotFound
      #user was not found, nothing to post
    end
  end

  protected
  def set_type
    case subject_type
          when Like::USER,  'user' then  self.subject_type = Like::USER
          when Like::ALBUM, 'album' then self.subject_type = Like::ALBUM
          when Like::PHOTO, 'photo' then self.subject_type = Like::PHOTO
    end
  end
end