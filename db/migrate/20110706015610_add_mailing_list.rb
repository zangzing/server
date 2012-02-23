class AddMailingList < ActiveRecord::Migration
  def self.up
    create_table :mailing_lists, :force => true do |t|
         t.string                 :name
         t.string                 :mailchimp_list_id,  :null => false
         t.string                 :category,      :null => false
         t.timestamps
       end
       add_index :mailing_lists, :mailchimp_list_id, :unique => true
       add_index :mailing_lists, :category

       # Seed Data
       MailingList.create( :name => 'Testing List', :mailchimp_list_id => '10ca465e13', :category => 'news' )
  end

  def self.down
    drop_table :mailing_lists
  end
end
