class CreatePhotoCommentEmailTemplate < ActiveRecord::Migration
  def self.up
    photo_comment       = Email.create( :name => :photo_comment)

    et = EmailTemplate.create( :email_id => photo_comment.id,
                          :mc_campaign_id =>"ec0a721172",
                          :category => "email.photocomment")

    photo_comment.update_attributes( :production_template_id => et.id )

  end

  def self.down
  end
end
