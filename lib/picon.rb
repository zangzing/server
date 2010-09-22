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

module Picon
  class << self

    def build( album )
      # Validate Arguments and cover
      return nil if album.nil?
      raise new Exception("Argument must be an Album") unless album.is_a? Album
      return nil if album.cover.nil?

      #Choose photos for stack
      stack = []
      album.photos.each do |p|
        stack << p.thumb_url if p.id!=album.cover.id
        break if stack.length >= 2
      end
      #Build picon and return it
      Processor.new(album.cover.thumb_url,:stack=>stack).make
    end

    @@hold_it =[]
    def test(count)
      photo1="http://alpha.dev.zangzing.s3.amazonaws.com/images/dZbzJ4V0mr34MJeJe7ePYv/dZbzJ4V0mr34MJeJe7ePYv_thumb.jpeg"
      photo2 ="http://bravo.dev.zangzing.s3.amazonaws.com/images/c88QEWV_Cr352veJe7ePYv/c88QEWV_Cr352veJe7ePYv_thumb.jpeg"
      photo3 ="http://alpha.dev.zangzing.s3.amazonaws.com/images/dZfehqR4Cr34tHacjbkp0q/dZfehqR4Cr34tHacjbkp0q_thumb.jpeg"
      cover = "http://alpha.dev.zangzing.s3.amazonaws.com/images/dKJ1NAVter35uDeJe7ePYv/dKJ1NAVter35uDeJe7ePYv_thumb.jpeg"
      dst = nil

      case count
        when 3: dst = Processor.new(cover,:stack=>[photo1,photo2]).make
        when 2: dst = Processor.new(cover,:stack=>[photo1]).make
        when 1: dst = Processor.new(cover).make
      end

      @@hold_it << dst
      puts "Picon was successfully created into #{File.expand_path( dst.path )}"
    end

  end

  class Processor
    # Creates a Picon
    def initialize file, options = {}
      if file.is_a?(File)
        @cover = file
      else
        @cover = download( file )
      end
      @stack=[]
      options[:stack].each {|f| (f.is_a?(File) ? @stack << f : @stack << download( f ))} unless options[:stack].nil?
    end

    # Performs the conversion of the +file+ into a thumbnail. Returns the Tempfile
    # that contains the new image.
    def make
      dst = Tempfile.new(['picon', 'png'].compact.join("."))
      dst.binmode
      begin
        parameters = []
        @stack.each do |s|
          parameters << File.expand_path(s.path)
        end
        parameters << File.expand_path(@cover.path)
        parameters << picon_command
        parameters << File.expand_path(dst.path)
        parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")

        Paperclip.run("convert", parameters)
      rescue Paperclip::PaperclipCommandLineError => e
        raise Paperclip::PaperclipError, "There was an error building the picon for for #{@cover} "+ e
      end
      dst
    end

    private
    #downloads uris into temp file
    def download( image_uri )
      temp_file =  Tempfile.new('thump4picon', "#{Rails.root}/tmp")
      open(image_uri)  do |src|
        temp_file.write(src.read)
      end
      temp_file.flush
      temp_file.close()
      temp_file
    end

    # Returns the command ImageMagick's +convert+ needs to make a Picon
    def picon_command
      cmd = []
      cmd << "-bordercolor white  -border 5"                        # Add 5px white border
      cmd << "-bordercolor none  -background  none"                 # Clear background
      case @stack.length
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
end