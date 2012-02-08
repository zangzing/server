# encapsulates logic to help with mega groups conversion project migration
# separated out here to ease development
class GroupsMigrationHelper

  # given a set of users ids which can be email or id, add to new acl
  def self.convert_rights(acl, user_ids, new_role)
    user_ids.each do |user_id|
      user_id_num = Integer(user_id) rescue false
      # verify that the user actually exists
      if user_id_num != false
        user = User.find_by_id(user_id_num)
      else
        # user_id is actually an email, create an auto_by_contact user
        email = user_id
        user = User.find_by_email(email)
        if user.nil?
          puts "Creating automatic user for email of #{email}"
          user = User.find_by_email_or_create_automatic(email, '', true)
          if user.nil?
            puts "Unable to create user for email: #{email}, dropping from acl"
          end
        end
      end
      if user
        # now put it into the new acl manager
        acl.add_user(user, new_role)
      end
    end
  end

  # migrate the system rights
  def self.system_rights
    puts "Migrating system rights"
    from_roles = [OldSystemRightsACL::USER_ROLE, OldSystemRightsACL::MODERATOR_ROLE, OldSystemRightsACL::SUPPORT_HERO_ROLE, OldSystemRightsACL::ADMIN_ROLE]
    to_roles = [SystemRightsACL::USER_ROLE, SystemRightsACL::MODERATOR_ROLE, SystemRightsACL::SUPPORT_HERO_ROLE, SystemRightsACL::ADMIN_ROLE]

    acl = SystemRightsACL.singleton
    from_roles.each_index do |i|
      user_ids = OldSystemRightsACL.singleton.get_users_with_role(from_roles[i], true)
      convert_rights(acl, user_ids, to_roles[i])
    end
    true
  end

  # migrate the albums acls
  def self.album_acls
    puts "Migrating album acls"
    from_roles = [OldAlbumACL::VIEWER_ROLE, OldAlbumACL::CONTRIBUTOR_ROLE, OldAlbumACL::ADMIN_ROLE]
    to_roles = [AlbumACL::VIEWER_ROLE, AlbumACL::CONTRIBUTOR_ROLE, AlbumACL::ADMIN_ROLE]

    # check every album
    Album.all.each do |album|
      puts "Migrating ACLs for Album: #{album.name}"
      old_acl = OldAlbumACL.new(album.id)
      from_roles.each_index do |i|
        user_ids = old_acl.get_users_with_role(from_roles[i], true)
        convert_rights(album.acl, user_ids, to_roles[i])
      end
    end
    true
  end

  def self.remove_invite_activities
    puts "Deleting all invite activities"
    Activity.delete_all("type = 'InviteActivity'")
    true
  end

  # back up the current database state
  def self.backup_current_database
    db_config = DatabaseConfig.config
    file_name = Time.now().strftime( "%Y%m%d_%H%M%S_#{Rails.env}.dump")
    cmd =[]
    cmd << "mysqldump"   #command
    cmd << "-u#{db_config[:username]}"
    cmd << " -p#{db_config[:password]}" if db_config[:password]
    cmd << ( db_config[:host] ? " -h#{db_config[:host]}" : "-h localhost" )
    cmd << "#{db_config[:database]}"
    cmd << "> /media/ephemeral0/backup/#{file_name}"
    cmd_line = cmd.flatten.compact.join(" ").strip.squeeze(" ")
    puts cmd_line
    `#{cmd_line}`
  end

  # used if you need to restore the backed up database
  def self.restore_database(path)
    db_config = DatabaseConfig.config
    cmd =[]
    cmd << "mysql"   #command
    cmd << "-u#{db_config[:username]}"
    cmd << " -p#{db_config[:password]}" if db_config[:password]
    cmd << ( db_config[:host] ? " -h#{db_config[:host]}" : "-h localhost" )
    #cmd << "--verbose"
    cmd << "--debug-info"
    cmd << "#{db_config[:database]}"
    cmd << "< #{path}"
    cmd_line = cmd.flatten.compact.join(" ").strip.squeeze(" ")
    puts cmd_line
    `#{cmd_line}`
  end

  def self.migrate_all
    backup_current_database
    system_rights
    album_acls
    remove_invite_activities
    true
  end

end