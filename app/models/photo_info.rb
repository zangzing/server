class PhotoInfo < ActiveRecord::Base
  belongs_to :photo

  validates_presence_of :photo

  def self.factory(meta_data)
    PhotoInfo.new(:metadata => meta_data.to_json)
  end
  
  def self.get_image_metadata(file_name)
    exif_tags = nil
    iptc_tags = nil
    file_tags = nil

    begin
      # tool must be in same dir as paperclip command path (or a sym link to it)
      # the following asks exiftool to return json formatted data grouped by type
      # and only requests EXIF and IPTC currently
      cmd = %Q[-j -g -EXIF:All -IPTC:All -FILE:All -d "%Y-%m-%dT%H:%M:%S" "#{file_name}"]

      src_data = ZZ::CommandLineRunner.run('exiftool', cmd)
      if src_data.nil?
        raise "No data was returned from call to #{cmd}"
      end
      
      # the exiftool -j option returns a nice and convenient json formatted result so turn into ruby object
      metainfo = JSON.parse(src_data)
      data_set = metainfo[0]
      if data_set
        # pull out the group tags that we care about
        exif_tags = data_set["EXIF"]
        iptc_tags = data_set["IPTC"]
        file_tags = data_set["File"]
      end
    rescue => ex
      raise ex, "There was an error getting metadata with exiftool from #{file_name} : " + ex.to_s
    end

    {:EXIF => exif_tags, :IPTC => iptc_tags, :File => file_tags}
  end

  def self.decode_gps_coord(source_string, coord_ref)
    return unless source_string
    #Here we can determine the source format and decode it
    #Case 1
    if match = source_string.match(/(\d+)\/(\d+), (\d+)\/(\d+), (\d+)\/(\d+)/i)
      return ( match[1].to_f/match[2].to_f + match[3].to_f/match[4].to_f/60 + match[5].to_f/match[6].to_f/3600 ) * (['N','E'].include?(coord_ref) ? 1 : -1)
    end
    #Case 2
    #.... NMEA maybe...
  end


private

  def self.fix_date_values(property_hash)
    property_hash.each do |key, value|
      value.gsub!(/(\d{4}):(\d{2}):(\d{2})/i, '\1/\2/\3') if key.include?('Date')
    end
  end

end
