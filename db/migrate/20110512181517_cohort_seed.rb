class CohortSeed < ActiveRecord::Migration
  def self.up
    # we've manually done this on production so just skip it if we try to run in production
    if Rails.env == 'photos_production'
      puts "Skipping Cohort Migration on #{Rails.env} since done manually"
      return
    end

    add_column :users, :cohort, :integer

    add_index :users, :cohort


    # set initial values for everything before May 1 2011 to be in cohort 1
    # and everything after to be in cohort 2, this migration only makes sense
    # if we run it once in May, it should not be run after that
    cutoff = User.cohort_base >> 1
    cutoff_str = cutoff.to_s(:db)
    execute("UPDATE users SET cohort = 1 WHERE created_at < '#{cutoff_str}' AND cohort IS NULL")
    execute("UPDATE users SET cohort = 2 WHERE created_at >= '#{cutoff_str}' AND cohort IS NULL")
  end

  def self.down
    remove_column :users, :cohort
  end
end
