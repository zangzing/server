begin
  namespace :mobileme do
    task :reprocess => :environment do
      #puts 'starting...'
      #
      #Photo.where('state = "error" and source="mobileme" and (error_message="404: Not Found" or error_message="406: Not Acceptable" or error_message="Not a supported image type, you passed: text/html" or error_message="private method `scan\' called for nil:NilClass") and source_screen_url != "/images/password-protected-view-after-import.png"').each do |photo|
      #
      #  web_url = photo.source_screen_url
      #  large_url = web_url.sub("/web.", "/large.")
      #  url = large_url
      #
      #  # try the large
      #  puts "testing\t#{url}"
      #  uri = URI::parse(URI.escape(url))
      #  http = Net::HTTP.new(uri.host)
      #  http.request_head(uri.request_uri) do |response|
      #    if response.code != "200"
      #      url = web_url
      #    end
      #  end
      #  puts "using\t#{url}"
      #  puts
      #
      #  photo.state = 'assigned'
      #  photo.save!
      #
      #  ZZ::Async::GeneralImport.enqueue(photo.id, url)
      #
      #end
      #
      #
      #puts 'done!'
    end
  end
end




