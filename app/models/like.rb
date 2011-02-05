class Like < ActiveRecord::Base
  attr_accessible :user_id, :subject_id, :subject_type
 #Like Subject Types
  USER = 'U'
  ALBUM='A'
  PHOTO='P'

  def self.toggle( user_id, subject_id, subject_type )
    begin
      case subject_type
        when USER then  subject = User.find( subject_id )
        when ALBUM then subject = Album.find( subject_id )
        when PHOTO then subject = Photo.find( subject_id )
      end
    rescue ActiveRecord::RecordNotFound 
      # the subject does not exist, nothing to do.
      return false
    end
    
    #if the user was not logged in when she liked the subject, there is nothing else to do
    if user_id.nil?
      #only increase the subject's like counter, no user logged in. Can't decrease 'Can't create Like Record
      LikeCounter.increase( subject_id, subject_type )
    else
      begin
        Like.create( :user_id => user_id, :subject_id => subject_id, :subject_type => subject_type)
        #User Like Record created, increase the subject's like counter
        LikeCounter.increase( subject_id, subject_type )
      rescue  ActiveRecord::RecordNotUnique
        #User Like Record exists, so lets turn it off and decrease the counter
        Like.find_by_user_id_and_subject_id( user_id, subject_id).destroy
        LikeCounter.decrease( subject_id )
      end
    end
    return true
  end
end