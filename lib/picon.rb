require 'open-uri'


class Tempfile
  # Due to how ImageMagick handles its image format conversion and how Tempfile
   # handles its naming scheme, it is necessary to override how Tempfile makes
   # its names so as to allow for file extensions. Idea taken from the comments
   # on this blog post:
   # http://marsorange.com/archives/of-mogrify-ruby-tempfile-dynamic-class-definitions

    def make_tmpname(basename, n)
      # force tempfile to use basename's extension if provided
      ext = File::extname(basename)
      # force hyphens instead of periods in name
      sprintf('%s%d-%d%s', File::basename(basename, ext), $$, n, ext)
    end
end

module Picon
class << self
  @@hold_it =[]
  def test()
     photo1="http://alpha.dev.zangzing.s3.amazonaws.com/images/dZbzJ4V0mr34MJeJe7ePYv/dZbzJ4V0mr34MJeJe7ePYv_thumb.jpeg"
     photo2 ="http://bravo.dev.zangzing.s3.amazonaws.com/images/c88QEWV_Cr352veJe7ePYv/c88QEWV_Cr352veJe7ePYv_thumb.jpeg"
     photo3 ="http://alpha.dev.zangzing.s3.amazonaws.com/images/dZfehqR4Cr34tHacjbkp0q/dZfehqR4Cr34tHacjbkp0q_thumb.jpeg"          
     cover = "http://alpha.dev.zangzing.s3.amazonaws.com/images/dKJ1NAVter35uDeJe7ePYv/dKJ1NAVter35uDeJe7ePYv_thumb.jpeg"
     dst = Processor.new(cover,:stack=>[photo1,photo2]).make
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
      cover = @cover
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

        success = Paperclip.run("convert", parameters)
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error building the picon for for #{@cover}" 
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
     cmd << "-bordercolor white  -border 6"
     cmd << "-bordercolor grey60 -border 1"
     cmd << "-bordercolor none  -background  none"
     cmd << "\\( -clone 0 -rotate -20 \\)" #back
     cmd << "\\( -clone 1 -rotate +10 \\)" #middle
     cmd << "\\( -clone 2 -rotate +40 \\)" #cover
     cmd << "-delete 0,1,2"
     cmd << "-border 100x80  -gravity center"
     cmd << "-crop 200x160+0+0  +repage  -flatten  -trim +repage"
     cmd << "-background black \\( +clone -shadow 60x4+4+4 \\) +swap"
     cmd << "-background none  -flatten"
     cmd
    end
end
end