require 'open-uri'

module ZZ
  class TempfileWithExtension < Tempfile
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

      if album.cover.nil?
        cover = album.photos.find(:order => 'created_at DESC').first
      else
        cover = album.cover
      end

      #The stack is a pile of urls with the cover at the end.
      stack = []
      album.photos.each do |p|   # choose a push photos (which are not the cover )into stack
        stack << p.thumb_url unless p.id == cover.id
        break if stack.length >= 2
      end
      stack<< cover.thumb_url # push the cover onto the stack last
      create( stack ) #Build picon and return it
    end

    private
    # Creates a Picon with file as the cover and  options[:stack] for the stack behind the cover
    def self.create( photo_stack )
      return nil if photo_stack.nil?

      #download each photo in the stack if not already a file
      file_stack=[]
      photo_stack.each do |p|
        if p is_a?(File)
          file_stack << p
        else
          file_stack << download( p )
        end
      end

      #create the destination file
      dst = ZZ::TempfileWithExtension.new('picon.png')
      dst.binmode

      begin
        parameters = []
        file_stack.each do |s|
          parameters << File.expand_path(s.path)  #the last one in the command line is the cover
        end
        parameters << build_picon_command( file_stack )
        parameters << File.expand_path(dst.path)
        parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")

        Paperclip.run("convert", parameters)
      rescue Paperclip::PaperclipCommandLineError => e
        raise Paperclip::PaperclipError, "There was an error building the picon "+ e
      end
      dst
    end

    #downloads uris into temp file
    def self.download( image_uri )
      temp_file =  Tempfile.new('thumb4picon')
      open(image_uri)  do |src|
        temp_file.write(src.read)
      end
      temp_file.flush
      temp_file.close()
      temp_file
    end

    # Returns the command ImageMagick's +convert+ needs to make a Picon
    def self.build_picon_command( file_stack )
      cmd = []
      cmd << "-bordercolor white  -border 5"                        # Add 5px white border
      cmd << "-bordercolor none  -background  none"                 # Clear background
      case file_stack.length
        when 1   # use the cover without rotation
        when 2   # rotate cover and 1 background
          cmd << "\\( -clone 0 -rotate -"+(rand(10)+0).to_s+" \\)" #middle
          cmd << "\\( -clone 1 -rotate +0 \\)" #cover
          cmd << "-delete 0,1"
        else # rotate cover and 2 backgrounds
          cmd << "\\( -clone 0 -rotate -"+(rand(5)+10).to_s+" \\)" #20 back
          cmd << "\\( -clone 1 -rotate +"+(rand(5)+0).to_s+" \\)" #10 middle
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
end
