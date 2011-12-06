class AddLastImportAllToIdentity < ActiveRecord::Migration
  def self.up
    add_column    :identities, :last_import_all, :datetime
  end

  def self.down
    remove_column    :identities, :last_import_all
  end
end
