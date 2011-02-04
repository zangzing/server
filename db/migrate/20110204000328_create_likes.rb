class CreateLikes < ActiveRecord::Migration
 def self.up
    create_table :likes,:guid => false, :force => true do |t|
        t.references_with_guid  :user,    :null => false
        t.references_with_guid  :subject, :null => false
        t.string                :subject_type,  :null => false
    end
    add_index :likes, :user_id
    add_index :likes, :subject_id
    add_index :likes, [:user_id, :subject_id],  :unique => true, :name => "userid_subjectid_index"
  end

  def self.down
    drop_table :likes
  end
end
