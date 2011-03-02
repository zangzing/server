class LikeCounter < ActiveRecord::Base
  attr_accessible :subject_id, :count

  def self.increase( subject_id )
      counter = LikeCounter.find_or_create_by_subject_id( subject_id )
      counter.increase unless counter.nil?
  end

  def self.decrease( subject_id)
    begin
      counter = LikeCounter.find_by_subject_id( subject_id )
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