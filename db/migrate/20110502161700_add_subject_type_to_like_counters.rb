class AddSubjectTypeToLikeCounters < ActiveRecord::Migration
  def self.up
    add_column    :like_counters, :subject_type, :string
    add_index     :like_counters,  [:subject_id, :subject_type], :unique => true
    remove_index  :like_counters,  :subject_id

    add_index    :likes, [:user_id, :subject_id, :subject_type ], :unique => true
    remove_index :likes, :name=> :userid_subjectid_index
  end

  def self.down
  end
end
