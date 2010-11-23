require 'open-uri'

class Tempfile
  # Due to how ImageMagick handles its image format conversion and how Tempfile
  # handles its naming scheme, it is necessary to override (monkey patch) how Tempfile makes
  # its names so as to allow for file extensions. Idea taken from the comments
  # on this blog post:
  # http://marsorange.com/archives/of-mogrify-ruby-tempfile-dynamic-class-definitions
  #

  def make_tmpname(basename, n)
    # force tempfile to use basename's extension if provided
    ext = File::extname(basename)
    # force hyphens instead of periods in name
    sprintf('%s%d-%d%s', File::basename(basename, ext), $$, n, ext)
  end
end

class Picon
    def self.make( album )
      # Validate Arguments and cover
      return nil if album.nil?
      raise "Argument must be an Album" unless album.is_a? Album
      return nil if album.cover.nil?

      #Choose photos for stack
      stack = []
      album.photos.find(:all, :order => 'created_at DESC').each do |p|
        stack << p.thumb_url if p.id!=album.cover.id
        break if stack.length >= 2
      end
      
      #Build picon and return it
      create(album.cover.thumb_url,:stack=>stack)
    end

    # Creates a Picon with file as the cover and  options[:stack] for the stack behind the cover
    def self.create( file, options ={})
      # Download cover file if not already a file
      cover = nil
      if file.is_a?(File)
        cover = file
      else
        cover = download( file )
      end

      #download each photo in the stack if not already a file
      stack=[]
      options[:stack].each {|f| (f.is_a?(File) ? stack << f : stack << download( f ))} unless options[:stack].nil?

      dst = Tempfile.new(['picon', 'png'].compact.join("."))
      dst.binmode
      begin
        parameters = []
        stack.each do |s|
          parameters << File.expand_path(s.path)
        end
        parameters << File.expand_path(cover.path)
        parameters << build_picon_command( stack )
        parameters << File.expand_path(dst.path)
        parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")

        Paperclip.run("convert", parameters)
      rescue Paperclip::PaperclipCommandLineError => e
        raise Paperclip::PaperclipError, "There was an error building the picon for for #{cover} "+ e
      end
      dst
    end

    private
    #downloads uris into temp file
    def self.download( image_uri )
      temp_file =  Tempfile.new('thump4picon', "#{Rails.root}/tmp")
      open(image_uri)  do |src|
        temp_file.write(src.read)
      end
      temp_file.flush
      temp_file.close()
      temp_file
    end

    # Returns the command ImageMagick's +convert+ needs to make a Picon
    def self.build_picon_command( stack )
      cmd = []
      cmd << "-bordercolor white  -border 5"                        # Add 5px white border
      cmd << "-bordercolor none  -background  none"                 # Clear background
      case stack.length
        when 0   # use the cover without rotation
        when 1   # rotate cover and 1 background
          cmd << "\\( -clone 0 -rotate -"+(rand(20)+10).to_s+" \\)" #middle
          cmd << "\\( -clone 1 -rotate +0 \\)" #cover
          cmd << "-delete 0,1"
        else # rotate cover and 2 backgrounds
          cmd << "\\( -clone 0 -rotate -"+(rand(10)+20).to_s+" \\)" #back
          cmd << "\\( -clone 1 -rotate +"+(rand(10)+10).to_s+" \\)" #middle
          cmd << "\\( -clone 2 -rotate +0 \\)" #cover
          cmd << "-delete 0,1,2"
      end
      cmd << "-border 100x80  -gravity center"                      #center stack
      cmd << "-crop 200x160+0+0  +repage  -flatten  -trim +repage"
      cmd << "-background black \\( +clone -shadow 50x2+0+0 \\) +swap"  #shadow args opacityXsigma+XAngle+YAngle
      cmd << "-background none  -flatten"
      cmd
    end
end   
