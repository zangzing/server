class CreateOauthTables < ActiveRecord::Migration
  def self.up
    create_table :client_applications,:guid => false,:force => true do |t|
      t.string :name
      t.string :url
      t.string :support_url
      t.string :callback_url
      t.string :key, :limit => 20
      t.string :secret, :limit => 40
      t.references_with_guid :user

      t.timestamps
    end
    add_index :client_applications, :key, :unique
    
    create_table :oauth_tokens,:guid => false,:force => true do |t|
      t.references_with_guid :user, :null => true
      t.string  :agent_id 
      t.string :type, :limit => 20
      t.integer :client_application_id
      t.string :token, :limit => 20
      t.string :secret, :limit => 40
      t.string :callback_url
      t.string :verifier, :limit => 20
      t.timestamp :authorized_at, :invalidated_at
      t.timestamps
    end
    
    add_index :oauth_tokens, :token, :unique
    
    create_table :oauth_nonces, :guid => false,:force => true do |t|
      t.string :nonce
      t.integer :timestamp

      t.timestamps
    end
    add_index :oauth_nonces,[:nonce, :timestamp], :unique   
  end

  def self.down
    drop_table :client_applications
    drop_table :oauth_tokens
    drop_table :oauth_nonces
  end

end
