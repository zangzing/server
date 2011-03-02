class SetInitialAutoIncrements < ActiveRecord::Migration
  def self.up
    execute('ALTER TABLE activities AUTO_INCREMENT = 19900073723;')
    execute('ALTER TABLE albums AUTO_INCREMENT = 29900073723;')
    execute('ALTER TABLE bench_test_photo_gens AUTO_INCREMENT = 39900073723;')
    execute('ALTER TABLE bench_test_resque_no_ops AUTO_INCREMENT = 49900073723;')
    execute('ALTER TABLE bench_test_s3s AUTO_INCREMENT = 59900073723;')
    execute('ALTER TABLE client_applications AUTO_INCREMENT = 69900073723;')
    execute('ALTER TABLE contacts AUTO_INCREMENT = 79900073723;')
    execute('ALTER TABLE contributors AUTO_INCREMENT = 89900073723;')
    execute('ALTER TABLE follows AUTO_INCREMENT = 99900073723;')
    execute('ALTER TABLE identities AUTO_INCREMENT = 109900073723;')
    execute('ALTER TABLE like_counters AUTO_INCREMENT = 119900073723;')
    execute('ALTER TABLE likes AUTO_INCREMENT = 129900073723;')
    execute('ALTER TABLE oauth_nonces AUTO_INCREMENT = 139900073723;')
    execute('ALTER TABLE oauth_tokens AUTO_INCREMENT = 149900073723;')
    execute('ALTER TABLE photo_infos AUTO_INCREMENT = 159900073723;')
    execute('ALTER TABLE photos AUTO_INCREMENT = 169900073723;')
    execute('ALTER TABLE recipients AUTO_INCREMENT = 179900073723;')
    execute('ALTER TABLE sessions AUTO_INCREMENT = 229900073723;')
    execute('ALTER TABLE shares AUTO_INCREMENT = 189900073723;')
    execute('ALTER TABLE slugs AUTO_INCREMENT = 199900073723;')
    execute('ALTER TABLE upload_batches AUTO_INCREMENT = 209900073723;')
    execute('ALTER TABLE users AUTO_INCREMENT = 249900073723;')
  end

  def self.down
  end
end
