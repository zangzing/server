class AddSubjectToActivity < ActiveRecord::Migration

  def self.up
   remove_index  :activities, :album_id
   rename_column :activities, :album_id, :subject_id
   add_column    :activities, :subject_type, :string, :null => false

   Activity.reset_column_information
   Activity.all.each do |a|
       a.subject_type = "Album"
       a.save
   end

   add_index    :activities, [:subject_id, :subject_type ]
   add_index    :activities, [:user_id, :subject_id, :subject_type ]
  end

  def self.down
    rename_column :activities, :subject_id, :album_id
    add_index :activities, :album_id
    remove_column :activities, :subject_type
  end
end
