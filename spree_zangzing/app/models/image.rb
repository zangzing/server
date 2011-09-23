#
#   Copyright 2011 ZangZing LLC. All rights reserved. www.zangzing.com
#


# The spree image uses paperclip, we do not want to use paperclip, we will
# use the image to store a url and alt text.

class Image < Asset
   alias_attribute :description, :alt
   alias_attribute :url, :attachment_file_name

   # This definition gets around a block inside the spree
   # Spree::BaseHelper used for setting up paperclip. By
   # returning an empty array, the block does not do anything.
    def self.attachment_definitions
      {:attachment => { :styles => {}}}
    end

    def attachment
      @attachment ||= Attachment.new( self )
    end

   class Attachment

       def initialize( image )
         @image = image
       end

       def url( size )
           return @image.url
       end
   end

end

