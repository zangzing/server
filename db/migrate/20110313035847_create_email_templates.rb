class CreateEmailTemplates < ActiveRecord::Migration

  def self.up
    create_table :emails, :force => true do |t|
      t.string                 :name,             :null => false
      t.integer                :production_template_id
      t.text                   :params
      t.text                   :method
      t.timestamp
    end
    add_index :emails, :name

    create_table :email_templates, :force => true do |t|
      t.integer                :email_id,         :null => false
      t.string                 :name,             :null => false
      t.string                 :mc_campaign_id,   :default => ""
      t.string                 :from_name
      t.string                 :from_address
      t.string                 :reply_to
      t.string                 :subject
      t.string                 :category
      t.text                   :html_content
      t.text                   :text_content
      t.timestamps
    end
    add_index :email_templates, :name

    print "Creating System Emails...\n"
    photos_ready        = Email.create( :name => :photos_ready)
    password_reset      = Email.create( :name => :password_reset)
    album_shared        = Email.create( :name => :album_shared)
    album_liked         = Email.create( :name => :album_liked)
    photo_liked         = Email.create( :name => :photo_liked)
    user_liked          = Email.create( :name => :user_liked)
    contribution_error  = Email.create( :name => :contribution_error)
    album_updated       = Email.create( :name => :album_updated)
    contributor_added   = Email.create( :name => :contributor_added)
    welcome             = Email.create( :name => :welcome)

    print "Creating System Email Templates."
    et = EmailTemplate.create( :email_id => photos_ready.id,
                          :mc_campaign_id =>"ed39f93a53",
                          :reply_to => "<%=@album.short_email%>",
                          :category => "email.photosready")
    photos_ready.update_attributes( :production_template_id => et.id )
    print "."
    et = EmailTemplate.create( :email_id => password_reset.id,
                          :mc_campaign_id =>"0dfd8b828a",
                          :category => "email.password")
    password_reset.update_attributes( :production_template_id => et.id )
    print "."
    et = EmailTemplate.create( :email_id => album_shared.id,
                          :mc_campaign_id =>"e427cb2a77",
                          :category => "email.albumshared")
    album_shared.update_attributes( :production_template_id => et.id )
    print "."
    et = EmailTemplate.create( :email_id => album_liked.id,
                          :mc_campaign_id =>"54bf6462bd",
                          :category => "email.albumliked")
    album_liked.update_attributes( :production_template_id => et.id )
    print "."
    et = EmailTemplate.create( :email_id => photo_liked.id,
                          :mc_campaign_id =>"229a03ecff",
                          :category => "email.photoliked")
    photo_liked.update_attributes( :production_template_id => et.id )
    print "."
    et = EmailTemplate.create( :email_id => user_liked.id,
                          :mc_campaign_id =>"1af6506f54",
                          :category => "email.userliked")
    user_liked.update_attributes( :production_template_id => et.id )
    print "."
    et = EmailTemplate.create( :email_id => contribution_error.id,
                          :mc_campaign_id =>"2453d696c7",
                          :category => "email.contributionerror")
    contribution_error.update_attributes( :production_template_id => et.id )
    print "."
    et = EmailTemplate.create( :email_id => album_updated.id,
                          :mc_campaign_id =>"cd154a1de5",
                          :category => "email.albumupdated")
    album_updated.update_attributes( :production_template_id => et.id )
    print "."
    et = EmailTemplate.create( :email_id => contributor_added.id,
                          :mc_campaign_id =>"bcbed116ba",
                          :reply_to => "<%=@album.short_email%>",
                          :category => "email.contributorinvite")
    contributor_added.update_attributes( :production_template_id => et.id )
    print "."
    et = EmailTemplate.create( :email_id => welcome.id,
                          :mc_campaign_id =>"9137f37b86",
                          :category => "email.welcome")
    welcome.update_attributes( :production_template_id => et.id )
    print ".\n"
    print "Dynamic Email Template System Setup!\n"

  end

  def self.down
    drop_table :emails
    drop_table :email_templates
  end
end
