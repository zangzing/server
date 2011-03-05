class AddUserPreferencesToExistingUsers < ActiveRecord::Migration
  def self.up
    sql = ActiveRecord::Base.connection()
    q = []
    q << "insert into user_preferences (user_id)"
    q << "select id from users where id not in (select user_id from user_preferences);"
    statement = q.join(" ").strip.squeeze(" ")
    sql.execute( statement )
  end

  def self.down
  end
end
