class Commentable < ActiveRecord::Base
  has_many :comments


  def self.find_or_create_by_photo_id(photo_id)
    self.find_or_create_by_subject_type_and_subject_id('photo', photo_id)
  end

  def self.find_by_photo_id(photo_id)
    self.find_by_subject_type_and_subject_id('photo', photo_id)
  end

  def self.metadata_for_album_as_hash(album_id)
    album = Album.find(album_id)
    results = []
    album.photos.each do |photo|
      commentable = Commentable.find_by_photo_id(photo.id)
      if commentable
        results << commentable.metadata_as_hash
      end
    end

    return results
  end


  def metadata_as_hash
    return self.attributes
  end

  def comments_as_hash
    commentable_hash = self.attributes
    commentable_hash[:comments] = []

    self.comments.each do |comment|
      comment_hash = comment.attributes

      user = comment.user

      comment_hash[:user] = {
          :first_name => user.first_name,
          :last_name => user.first_name,
          :username => user.first_name,
          :profile_photo_url => user.profile_photo_url
      }


      commentable_hash[:comments] << comment_hash

    end

    return commentable_hash

  end
end