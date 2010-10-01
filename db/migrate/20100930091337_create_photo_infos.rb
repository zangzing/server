class CreatePhotoInfos < ActiveRecord::Migration
  def self.up
    create_table :photo_infos, :guid => false, :force => true do |t|
     t.references_with_guid  :photo
     t.binary :metadata, :limit => 10.kilobytes
    end

    add_column :photos, :length, :integer # length, witdh as ints populated with exif:ExifImageLength exif:ExifImageWidth
    add_column :photos, :width, :integer
    add_column :photos, :orientation, :integer #as int populated with exif:Orientation (orientation may range from 1..8)
    add_column :photos, :latitude, :float #as float (exif:GPSLatitude) negative for Southern latitudes positive for Northern(exif:GPSLatitudeRef)
    add_column :photos, :longitude, :float #as float (exif:GPSLongitude) negative for western, positive for eastern Longitudes (exif:GPSLongitudeRef)
  end

  def self.down
    drop_table :photo_infos
    remove_column :photos, :length, :width, :orientation, :latitude, :longitude
  end
end
