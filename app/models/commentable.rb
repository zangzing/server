class Commentable < ActiveRecord::Base
  has_many :comments


  def self.find_or_create_by_photo_id(photo_id)
    self.find_or_create_by_subject_type_and_subject_id('photo', photo_id)
  end

  def self.find_by_photo_id(photo_id)
    self.find_by_subject_type_and_subject_id('photo', photo_id)
  end

  def self.photo_comments_as_json(photo_id)
    commentable = Commentable.find_by_photo_id(photo_id)
    if commentable
      return commentable.comments_as_json
    else
      return {}
    end
  end

  def self.album_photos_metadata_as_json(album_id)
    results = []
    commentables = Commentable.find_by_sql("SELECT commentables.* FROM commentables, photos WHERE commentables.subject_type = 'photo' AND commentables.subject_id = photos.id AND photos.album_id = #{album_id.to_i}")
    commentables.each do |commentable|
      results << commentable.metadata_as_json
    end

    return results
  end


  def metadata_as_json
    return self.attributes
  end

  def comments_as_json
    commentable_hash = self.attributes
    commentable_hash['comments'] = []

    self.comments.each do |comment|
      comment_hash = comment.attributes

      user = comment.user

      comment_hash['user'] = {
          'first_name' => user.first_name,
          'last_name' => user.first_name,
          'username' => user.first_name,
          'profile_photo_url' => user.profile_photo_url
      }


      commentable_hash['comments'] << comment_hash

    end

    return commentable_hash

  end
end