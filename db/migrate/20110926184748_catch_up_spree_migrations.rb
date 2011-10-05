class CatchUpSpreeMigrations < ActiveRecord::Migration
  def self.up
      ENV['VERSION']='20110725180030' #20110725180030_create_spree_tables.rb
      Rake::Task['db:migrate:up'].invoke
      ENV['VERSION']='20110725181819' #20110725181819_zangzing_modifications_for_spree.rb
      Rake::Task['db:migrate:up'].invoke
      ENV['VERSION']='20110729182150' #20110729182150_add_kind_to_emails.rb
      Rake::Task['db:migrate:up'].invoke
      ENV['VERSION']='20110906210200' #20110906210200_add_commerce_emails
      Rake::Task['db:migrate:up'].invoke
      ENV['VERSION']='20110912123705' #20110912123705_add_photo_for_print_flag
      Rake::Task['db:migrate:up'].invoke
      ENV['VERSION']='20110912202350' #20110912202350_s3_pending_delete_photos
      Rake::Task['db:migrate:up'].invoke
      ENV['VERSION']='20110914233445' #20110914233445_add_ez_print_support
      Rake::Task['db:migrate:up'].invoke
      ENV['VERSION']=nil
  end

  def self.down
  end
end
