class AddKindToEmails < ActiveRecord::Migration
  def self.up
    add_column :emails, :kind, :string, :default => Email::TRANSACTIONAL

    Email.reset_column_information
    emails = Email.all
    emails.each do |email|
      case email.name
        when 'beta_invite'        then email.kind = Email::TRANSACTIONAL
        when 'welcome'            then email.kind = Email::TRANSACTIONAL
        when 'password_reset'     then email.kind = Email::TRANSACTIONAL
        when 'contribution_error' then email.kind = Email::TRANSACTIONAL
        when 'photos_ready'       then email.kind = Email::STATUS
        when 'album_liked'        then email.kind = Email::SOCIAL
        when 'photo_liked'        then email.kind = Email::SOCIAL
        when 'user_liked'         then email.kind = Email::SOCIAL
        when 'album_updated'      then email.kind = Email::SOCIAL
        when 'photo_shared'       then email.kind = Email::INVITES
        when 'album_shared'       then email.kind = Email::INVITES
        when 'contributor_added'  then email.kind = Email::INVITES
      end
      email.save
    end
  end

  def self.down
    remove_column :emails, :kind
  end
end
