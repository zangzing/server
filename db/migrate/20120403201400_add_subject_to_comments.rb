class AddSubjectToComments < ActiveRecord::Migration
    def self.up
      add_column :comments, :subject_id, :bigint, :null => false
      add_column :comments, :subject_type, :string, :null => false
      add_index  :comments, [:subject_id, :subject_type ], :name => "subjectid_subjecttype_index", :unique => false

      Comment.reset_column_information

      # adding the subject_id subject_type to comments to accelerate the
      # searches to create activity views.
      comments = Comment.all
      comments.each do |comment|
        comment.subject_id   = comment.commentable.subject_id
        comment.subject_type = comment.commentable.subject_type
        comment.save
      end

      #update the updaated_at date for all commentables to reflect date of last comment
      # to prevent rails from clobbering the change to updated_at we have to turn off
      # record_timestamps
      ActiveRecord::Base.record_timestamps = false
      commentables = Commentable.all
      commentables.each do |commentable|
        comments = commentable.comments.order('created_at DESC')
        if comments.count > 0
          latest_comment = comments.first
          commentable.updated_at = latest_comment.created_at
          commentable.save
        end
      end
      ActiveRecord::Base.record_timestamps = true
    end

    def self.down
      remove_column :comments, :subject_id
      remove_column :comments, :subject_type
    end
end
