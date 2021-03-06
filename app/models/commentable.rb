class Commentable < ActiveRecord::Base
  has_many :comments
  belongs_to :subject


  SUBJECT_TYPE_PHOTO = 'photo'

  def self.find_or_create_by_photo_id(photo_id)
    self.find_or_create_by_subject_type_and_subject_id(SUBJECT_TYPE_PHOTO, photo_id)
  end

  def self.find_by_photo_id(photo_id)
    self.find_by_subject_type_and_subject_id('photo', photo_id)
  end

  # expect subjects to be array of hashes
  # with :id and :type keys
  def self.find_by_subjects(subjects)
    db = Commentable.connection

    in_clause = subjects.collect { |subject |

      "(#{subject[:id].to_i}, #{db.quote(subject[:type].to_s)})"

    }.join(',')

    return Commentable.where("(subject_id, subject_type) IN (#{in_clause})")
  end

  def self.find_for_album_photos(album_id)
    return Commentable.find_by_sql("SELECT commentables.* FROM commentables, photos WHERE commentables.subject_type = 'photo' AND commentables.subject_id = photos.id AND photos.album_id = #{album_id.to_i}")
  end

  def self.photo_comments_as_json(photo_id)
    commentable = Commentable.find_by_photo_id(photo_id)
    if commentable
      return commentable.comments_as_json
    else
      return {}
    end
  end


  def metadata_as_json
    return self.attributes
  end

  def comments_as_json
    commentable_hash = self.attributes
    commentable_hash['comments'] = []

    self.comments.each do |comment|
      begin
        comment_hash = comment.as_json
        commentable_hash['comments'] << comment_hash
      rescue Exception => ex
        Rails.logger.error("skipping comment because of error (probably missing user) - #{ex.message}\n#{ex.backtrace}")
      end
    end

    return commentable_hash

  end


  def subject
    if self.subject_type == SUBJECT_TYPE_PHOTO
      begin
        return Photo.find(self.subject_id)
      rescue
        return nil
      end
    end
  end

  def subject=(subject)
    if subject.kind_of?(Photo)
      self.subject_type = SUBJECT_TYPE_PHOTO
      self.subject_id = subject.id
    else
      raise "subject can only be photo"
    end
  end


end