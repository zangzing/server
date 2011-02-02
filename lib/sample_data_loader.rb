require 'faker'
require 'aws/s3'

class SampleDataLoader

  USER_COUNT=25

  def initialize()
     initializeS3
     load_image_names
  end

  def create_all
    puts  "==> Loading Sample Data"
    create_users
    create_albums
    create_photos
    add_contributors
    puts  "==> Sample Data Ready!"
  end

  def create_users
    puts  "      Creating Users"
    @users = []
    USER_COUNT.times do |n|
      name  = Faker::Name.name
      password  = "password"
      email = "user#{n}@test.zangzing.com"
      @users[n]  = User.new(:name => name,
                           :username => "user#{n}",
                           :email => email,
                           :password => password,
                           :password_confirmation => password)
      @users[n].active = true
      @users[n].save!
      puts "        #{name} <#{email}>"
    end
    puts "      Done Creating Users"
  end

  def create_albums
    puts "      Creating Albums"
    # create albums for first 10 users max 100
    User.all(:limit => 10).each do |user|
      (rand(12)+5).times do

        album= nil;
        case rand(2)
          when 0: album = PersonalAlbum.new( :name => album_name()[0..49] )
          when 1: album = GroupAlbum.new(    :name => album_name()[0..49] )
        end
        user.albums << album
        album.save!
      end
      puts "        #{user.name} created #{user.albums.length} albums"
    end
    puts "      Done Creating Albums"
  end

  def create_photos
    puts "      Creating Photos"
    Album.all(:limit => 50).each do |album|
      puts "      Adding photos to album #{album.name}"
      (rand( 3 )+1).times do
        UploadBatch.close_open_batches( album.user.id, album.id )
        (rand( 20 )+1).times do
            new_photo(album, album.user)
        end
        UploadBatch.get_current( album.user.id, album.id ).save
        puts "          Batch of #{UploadBatch.get_current( album.user.id, album.id ).photos.length} photos added"
      end
    end
    puts "      Done Creating Photos...."
  end

  def create_follows
    puts "      Creating Follows..."
    User.all(:limit => 10).each do |user|
      rand(15).times do
        Follow.factory( user, users[rand(50)]).save
        Follow.factory( users[rand(50)], user).save
      end
    end
    puts "      Done Creating Follows"
  end

  def add_contributors
    puts "      Add Contributors..."
    users = User.all( :limit => USER_COUNT)
    GroupAlbum.all(:limit => 50 ).each do |album|
       (rand(5)+1).times do
         i = rand( users.length)
         c = Contributor.new()
         c.album_id = album.id
         c.user_id  = users[i].id
         c.name     = users[i].name
         c.email     = users[i].email
         c.last_contribution = Time.now()
         c.save
         (rand( 3 )+1).times do
            UploadBatch.close_open_batches( users[i].id, album.id )
            (rand( 15 )+1).times do
              new_photo(album, users[i])
            end
            UploadBatch.get_current( users[i].id, album.id ).save
            puts "          Batch of #{UploadBatch.get_current( users[i].id, album.id ).photos.length} photos added"
         end
       end
       (rand(5)+1).times do
          album.contributors.create( :name => Faker::Name.name,
                                     :email => 'email-contributor'+ Faker::Internet.user_name+'@test.zangzing.com' )
       end
    end
    puts "      Done Adding Contributors"
  end

  def album_name
    case rand( 5 )
      when 0: return Faker::Address.city
      when 1: return Faker::Internet.domain_word.capitalize+' '+Faker::Address.city
      when 2: return Faker::Name.name+'\'s '+event
      when 3: return Faker::Address.city+' '+ (rand(41)+1970).to_s
      when 4: return (rand(41)+1970).to_s+' '+Faker::Company.name+'\'s '+event
    end
  end

  def event
    %w(Roompah Rave Concert Tournament Wedding Party Baptism Reunion Marriage Bar-Mitzvah Christmas Hannukah Labor-day Memorial-day Camp Graduation Surgery Jury-Duty Driving-Test Confirmation Commencement Premiere Vacation Road-Trip Recital).rand
  end

  def initializeS3
    puts "      Initializing connection to S3..."
    @s3creds = YAML::load(ERB.new(File.read("#{Rails.root}/config/s3.yml")).result)[Rails.env].recursively_symbolize_keys!
     AWS::S3::Base.establish_connection!(
             :access_key_id => @s3creds[:access_key_id],
            :secret_access_key =>@s3creds[:secret_access_key]
     )
#     @s3buckets = Paperclip.options[:image_options][:s3buckets]
#     @s3options = {:access => :public_read }.merge( Paperclip.options[:image_options][:s3_headers] )
     puts "      S3 connection up"
  end




  def load_image_names()
     puts "        Analyzing existing images in  S3..."
     @image_names=[]
     @s3buckets.each do | bucket_name |
        @s3bucket = AWS::S3::Bucket.find( bucket_name )
        @s3bucket.objects.each do | o |
          matches = o.key.match(/^(.*)\/original\/(.*\.(jpeg|jpg))$/i)
          if !matches.nil?
            @image_names.insert( rand( @image_names.length ), { :key =>matches[0], :bucket => bucket_name, :path=>matches[1], :name=>matches[2] })
          end
        end
      @image_name_counter = 0
      puts "        Found and re-using #{@image_names.length.to_s} images in  S3 bucket #{ bucket_name }."
     end
     puts "        S3 Existing Image Array Ready..."
  end

  def image_name
   @image_name_counter = 0 if @image_name_counter >= @image_names.length-1
   return @image_names[@image_name_counter+=1]
  end

  def new_photo(album, user)
   i = image_name
   current_batch = UploadBatch.get_current( user.id, album.id )
   Photo.create(
          :user_id           => user.id,
          :album_id          => album.id,
          :upload_batch_id   => current_batch.id,
          :agent_id          => Faker::PhoneNumber.phone_number,
          :caption           => Faker::Lorem.sentence( rand(10) ),
          :capture_date      => Time.now - rand( 1000 ).days,
          :image_file_name   => i[:name],
          :image_path        => i[:path],
          :image_bucket      => i[:bucket],
          :state             => 'ready'
   )
  end
end




#  def test_photo_names (bucket_name)
#       puts "      Analyzing existing images in  S3 bucket #{ bucket_name } ..."
#       @s3bucket = AWS::S3::Bucket.find( bucket_name )
#       @s3bucket.objects.each do | o |
#         matches = o.key.match(/^(.*)\/(.*)_(original|thumb|medium)\.(jpeg|jpg)$/i)
#         if !matches.nil?
#          new_name = "#{matches[1]}/#{matches[3]}/#{matches[2]}.#{matches[4]}"
#          puts o.key + " ==> " + new_name
#          AWS::S3::S3Object.copy( o.key, new_name, bucket_name, @s3options )
#         end
#       end
#  end
#
# def delete_new (bucket_name)
#      puts "      Deleting new images in  S3 bucket #{ bucket_name } ..."
#       @s3bucket = AWS::S3::Bucket.find( bucket_name )
#       @s3bucket.objects.each do | o |
#         matches = o.key.match(/^(.*)\/(original)\/(.*)$/i)
#         if !matches.nil?
#          puts "deleting ==> "+o.key
#          o.delete
#         end
#       end
#  end


#def load_more_image_names()
#     bucket_name =  (@s3buckets.push @s3buckets.shift)[0]
#     puts "      Analyzing existing images in  S3 bucket #{ bucket_name } ..."
#     @s3bucket = AWS::S3::Bucket.find( bucket_name )
#     @s3bucket.objects.each do | o |
#       matches = o.key.match(/^(.*)\/original\/(.*\.(jpeg|jpg))$/i)
#      if !matches.nil?
#        @image_names << { :key =>matches[0], :bucket => bucket_name, :path=>matches[1], :name=>matches[2] }
#        #puts "path => #{matches[1]}  name => #{matches[2]}"
#      end
#     end
#     #@image_names.each {|o| puts o[:path]+"  "+o[:name]}
#     @image_name_counter = 0
#    puts "      Found and re-using #{@image_names.length.to_s} existing images."
#  end
#
  
