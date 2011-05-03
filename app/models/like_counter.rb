class LikeCounter < ActiveRecord::Base
  attr_accessible :subject_id, :subject_type, :count

  def self.increase( subject_id, subject_type )
      counter = LikeCounter.find_or_create_by_subject_id_and_subject_type( subject_id, subject_type)
      counter.increase unless counter.nil?
  end

  def self.decrease( subject_id, subject_type)
    begin
      counter = LikeCounter.find_by_subject_id_and_subject_type( subject_id, subject_type )
      counter.decrease unless counter.nil?
    rescue ActiveRecord::RecordNotFound
    end
  end

  def increase
    self.counter +=1
    self.save
  end

  def decrease
    self.counter -= 1
    if counter <= 0
      self.destroy
    else
      self.save
    end
  end
end