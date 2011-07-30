class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :commentables  do |t|
      t.column   :subject_type,   :string,  :null => false
      t.column   :subject_id,     :bigint,  :null => false
      t.column   :comments_count, :int,     :default => 0
      t.timestamps
    end

    add_index    :commentables, [:subject_id, :subject_type ], :name => "subjectid_subjecttype_index", :unique => true


    create_table :comments do |t|
      t.column   :commentable_id, :bigint, :null => false
      t.column   :user_id,        :bigint, :null => false
      t.column   :text,           :text,   :null => false
      t.timestamps
    end
  
    add_index    :comments, [:commentable_id]
    add_index    :comments, [:user_id]


    execute("ALTER TABLE commentables AUTO_INCREMENT = 269900073723;")
    execute("ALTER TABLE comments AUTO_INCREMENT = 279900073723;")


  end

  def self.down
    drop_table :comments
    drop_table :commentables
  end
end
