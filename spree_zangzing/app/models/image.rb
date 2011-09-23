#
#   Copyright 2011 ZangZing LLC. All rights reserved. www.zangzing.com
#


# The spree image uses paperclip, we do not want to use paperclip, we will
# use the image to store a url and alt text.

class Image < Asset
   alias_attribute :description, :alt
   alias_attribute :photo_id, :attachment_file_name

   validates_presence_of :photo_id

   def photo
     @photo ||= Photo.find( photo_id )
   end

   # This definition gets around a block inside the spree
   # Spree::BaseHelper used for setting up paperclip. By
   # returning an empty array, the block does not do anything.
    def self.attachment_definitions
      {:attachment => { :styles => {}}}
    end

   # this definition is to deal with spree expecting an image using
   # paperclip
    def attachment
      @attachment ||= Attachment.new( self )
    end


   class Attachment
       def initialize( image )
         @image = image
       end

       def url( size )
         case size
           when :mini
             @image.photo.stamp_url
           when :product
             @image.photo.screen_url
           when :screen
             @image.photo.screen_url
           when :full_screen
             @image.photo.full_screen_url
           else
             @image.photo.screen_url
         end
       end
   end

end

