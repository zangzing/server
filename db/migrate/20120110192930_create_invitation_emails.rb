class CreateInvitationEmails < ActiveRecord::Migration
  def self.up
    invite_to_join         = Email.create( :name => :invite_to_join)
    joined_from_invite     = Email.create( :name => :joined_from_invite)
  end

  def self.down
  end
end
