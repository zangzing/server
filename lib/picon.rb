require 'open-uri'

 # Due to how ImageMagick handles its image format conversion and how Tempfile
  # handles its naming scheme, it is necessary to override how Tempfile makes
  # its names so as to allow for file extensions. Idea taken from the comments
  # on this blog post:
  # http://marsorange.com/archives/of-mogrify-ruby-tempfile-dynamic-class-definitions
class ZZTempfile < Tempfile
    def make_tmpname(basename, n)
      # force tempfile to use basename's extension if provided
      ext = File::extname(basename)
      # force hyphens instead of periods in name
      sprintf('%s%d-%d%s', File::basename(basename, ext), $$, n, ext)
    end
end

class Picon

  @@temp_files = []

  def self.test()
     photo1 ="http://alpha.dev.zangzing.s3.amazonaws.com/images/dZfehqR4Cr34tHacjbkp0q/dZfehqR4Cr34tHacjbkp0q_thumb.jpeg"
     photo2="http://alpha.dev.zangzing.s3.amazonaws.com/images/dZbzJ4V0mr34MJeJe7ePYv/dZbzJ4V0mr34MJeJe7ePYv_thumb.jpeg"
     cover = "http://alpha.dev.zangzing.s3.amazonaws.com/images/dKJ1NAVter35uDeJe7ePYv/dKJ1NAVter35uDeJe7ePYv_thumb.jpeg"
     Picon.create(cover,photo1,photo2)
  end

  def self.create( cover_uri, photo1_uri, photo2_uri)
    cover_path = Picon.download( cover_uri )
    photo1_path = Picon.download( photo1_uri )
    photo2_path = Picon.download( photo2_uri )

    result = ZZTempfile.new('picon.png',"#{Rails.root}/tmp")
    result_path  = result.path
    puts("Building Picon....")
    cmd = "/usr/local/bin/convert #{photo1_path} #{photo2_path} #{cover_path}  \
     -bordercolor white  -border 6 \
     -bordercolor grey60 -border 1 \
     -bordercolor none  -background  none \
     \\( -clone 0 -rotate -20 \\) \
     \\( -clone 1 -rotate +10 \\) \
     \\( -clone 2 -rotate +40 \\) \
     -delete 0 -delete 1 -delete 2 -border 100x80  -gravity center \
     -crop 200x160+0+0  +repage  -flatten  -trim +repage \
     -background black \\( +clone -shadow 60x4+4+4 \\) +swap \
     -background none  -flatten \
     #{result_path}"

    puts("Picon CMD ====>  #{cmd} <<====")
    puts("Building Picon....")
    `#{cmd}`
    puts $?
    result.close()
    puts("Picon Built! Successfully into ==> #{ result.path }")
    Picon.cleanup
    @@temp_files << result
    return result
  end

  private
  def self.download( image_uri )
    temp_file =  Tempfile.new('thump4picon', "#{Rails.root}/tmp")
    open(image_uri)  do |src|
      temp_file.write(src.read)
    end
    temp_file.flush
    temp_file.close()
    @@temp_files << temp_file
    temp_file.path
  end

  def self.cleanup
    @@temp_files.each {|f| f.close(true)}
  end
end