namespace :debug do
  task :mobileme_video_urls => :environment do

    LogEntry.where(:source_type => "MobileMeConnector").each do |log_entry|
      puts "LogEntry##{log_entry.id}:"
      #log_entry.details.scan(/("\w*(video|movie)\w*"\s*:\s*"?[\d\w\s\:\_\-\+\.\/]+"?)/i).each do |match|
      log_entry.details.scan(/("\w*(video|movie)\w*"\s*:\s*(\d+|true|false|".*?"))/i).each do |match|
        puts "    "+match.first
      end
    end

  end
end
