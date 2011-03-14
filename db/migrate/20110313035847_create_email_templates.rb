class CreateEmailTemplates < ActiveRecord::Migration
  def self.up
    create_table :email_templates, :force => true do |t|
           t.string                 :name,             :null => false
           t.string                 :mc_campaign_id    :default => ""
           t.string                 :from_name
           t.string                 :from_address
           t.string                 :subject
           t.text                   :html_content
           t.text                   :text_content
           t.timestamps
       end
       add_index :email_templates, :name
  end

  def self.down
     drop_table :email_templates
  end
end
