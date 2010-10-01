class PhotoInfo < ActiveRecord::Base
  belongs_to :photo

  validates_presence_of :photo

  def self.factory(photo)
    return nil unless photo.local_image?
    all_tags = get_image_metadata(photo.local_image.to_file.path)
    PhotoInfo.new(:metadata => all_tags.to_json)
  end
  
  def self.get_image_metadata(file_name)
    exif_tags = {}
    iptc_tags = {}

    begin
      cmd = %Q[-verbose "#{file_name}"]
      src_data = Paperclip.run('identify', cmd)

      exif_regexp = /^\s{4}exif:(\w+): (.+)$/i
      src_data.scan(exif_regexp) do |groups|
        exif_tags[groups[0].strip] = groups[1].strip
      end
      fix_date_values(exif_tags)

      iptc_regexp = /^\s{6}(\w+)\[(\d+,\d+)\]:(.+)$/i
      src_data.scan(iptc_regexp) do |groups|
        #groups[1] is a tag code, i.e. [2,25]
        iptc_tags[groups[0].strip] = groups[2].strip
      end
      #fix_date_values(iptc_tags)
    rescue PaperclipCommandLineError
      raise PaperclipError, "There was an error getting metadata from #{file_name}" if whiny
    end

    {:EXIF => exif_tags, :IPTC => iptc_tags}
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
