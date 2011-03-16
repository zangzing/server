class CreateEmailTemplates < ActiveRecord::Migration

  def self.up
    create_table :emails, :force => true do |t|
      t.string                 :name,             :null => false
      t.integer                :email_template_id
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
  end

  def self.down
    drop_table :emails
    drop_table :email_templates
  end
end
