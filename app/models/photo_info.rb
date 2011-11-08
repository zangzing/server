class PhotoInfo < ActiveRecord::Base
  attr_accessible :id, :photo_id, :metadata
  belongs_to :photo

# the following is commented out because it has the side
# effect of loading the parent photo object when we do
# our batch inserts - we are fine without it since
# you only get at photo infos from the parent photo object
#  validates_presence_of :photo

  def self.factory(meta_data)
    PhotoInfo.new(:metadata => meta_data.to_json)
  end
  
  def self.get_image_metadata(file_name)
    begin
      # tool must be in same dir as paperclip command path (or a sym link to it)
      # the following asks exiftool to return json formatted data grouped by type
      # and only requests EXIF and IPTC currently
      cmd = %Q[-j -g -EXIF:All -IPTC:All -FILE:All -PNG:All -GIF:All -d "%Y-%m-%dT%H:%M:%S" "#{file_name}"]

      src_data = ZZ::CommandLineRunner.run('exiftool', cmd)
      if src_data.nil?
        raise "No data was returned from call to #{cmd}"
      end
      
      # the exiftool -j option returns a nice and convenient json formatted result so turn into ruby object
      metainfo = JSON.parse(src_data)
      data_set = metainfo[0]
      if data_set.nil?
        data_set = {}
      end
    rescue => ex
      raise ex, "There was an error getting metadata with exiftool from #{file_name} : " + ex.to_s
    end

    data_set
  end

  def self.decode_gps_coord(source_string, coord_ref)
    return unless source_string
    #Here we can determine the source format and decode it
    #Case 1
    if match = source_string.match(/(\d+)\/(\d+), (\d+)\/(\d+), (\d+)\/(\d+)/i)
      return ( match[1].to_f/match[2].to_f + match[3].to_f/match[4].to_f/60 + match[5].to_f/match[6].to_f/3600 ) * (['N','E'].include?(coord_ref) ? 1 : -1)
    end
    return nil
  end


private

  def self.fix_date_values(property_hash)
    property_hash.each do |key, value|
      value.gsub!(/(\d{4}):(\d{2}):(\d{2})/i, '\1/\2/\3') if key.include?('Date')
    end
  end

end
