require 'readline'

namespace :commerce do

  desc "Dump and Export Catalog to S3"
  task :export => :environment do
    rdm = ReferenceDataMover.new()
    rdm.export_commerce('rake')
  end

  desc "Import Commerce Catalog from S3"
  task :import => :environment do
    rdm = ReferenceDataMover.new()
    keys = rdm.commerce_export_file_list()

    keys.each_with_index do |key , i|
      puts " #{i+1}.- #{key.gsub('catalog_export/','')}"
    end
    print "Enter # of file  you would like to import?"
    index = Readline.readline().to_i
    key = keys[index -1]
    rdm.import( key )
  end

end

namespace :email do

  desc "Dump and Export Email System Tables to S3"
  task :export => :environment do
    rdm = ReferenceDataMover.new()
    rdm.export_email('rake')
  end

  desc "Import Email System Tables from S3"
  task :import => :environment do
    rdm = ReferenceDataMover.new()
    keys = rdm.email_export_file_list()

    keys.each_with_index do |key , i|
      puts " #{i+1}.- #{key.gsub(/.*_export\//,'')}"
    end
    print "Enter # of file  you would like to import?"
    index = Readline.readline().to_i
    key = keys[index -1]
    rdm.import( key )
  end

end

