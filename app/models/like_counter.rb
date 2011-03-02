class LikeCounter < ActiveRecord::Base
  attr_accessible :subject_id, :count


  def self.increase( subject_id )
    begin
      counter = LikeCounter.find_by_subject_id( subject_id )
      if counter.nil?
        LikeCounter.create( :subject_id => subject_id )
      else
        counter.increase unless counter.nil?
      end
    rescue ActiveRecord::RecordNotFound
      #the default value for a LikeCount is 1 so no need to increment it upon creation
      LikeCounter.create( :subject_id => subject_id)
    end
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