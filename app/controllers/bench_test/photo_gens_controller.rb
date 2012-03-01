#
# rails generate scaffold BenchTest/PhotoGen result_message:string start:datetime stop:datetime iterations:integer file_size:integer album_id:string user_id:string error_count:integer good_count:integer
#
class BenchTest::PhotoGensController < BenchTest::BenchTestsController
  # GET /bench_test/photo_gens
  # GET /bench_test/photo_gens.xml
  def index
    @bench_test_photo_gens = BenchTest::PhotoGen.order("created_at DESC").limit(5)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bench_test_photo_gens }
    end
  end

  # GET /bench_test/photo_gens/1
  # GET /bench_test/photo_gens/1.xml
  def show
    @bench_test_photo_gen = BenchTest::PhotoGen.find(params[:id])
    if @bench_test_photo_gen.start.nil?
      # no start time recorded yet, see if we can find info about first photo
      photo = Photo.find_by_user_id_and_album_id_and_caption(@bench_test_photo_gen.user_id,
        @bench_test_photo_gen.album_id,
        '1')
      if photo
        utime = photo.image_updated_at
        @bench_test_photo_gen.start = utime unless utime.nil?
      end
    end
    if @bench_test_photo_gen.stop.nil?
      last = @bench_test_photo_gen.iterations.to_s
      # no start time recorded yet, see if we can find info about first photo
      photo = Photo.find_by_user_id_and_album_id_and_caption(@bench_test_photo_gen.user_id,
        @bench_test_photo_gen.album_id,
        last)
      if photo
        utime = photo.updated_at # yes we really do want updated_at not image_update_at for the end time
        if utime && (photo.ready? || photo.error?)
          @bench_test_photo_gen.stop = utime

          # since this is last photo gather good/bad stats
          photos = Photo.find_all_by_user_id_and_album_id(@bench_test_photo_gen.user_id,
            @bench_test_photo_gen.album_id)
          good_count = 0
          error_count = 0
          photos.each do |photo|
            if photo.ready?
              good_count += 1
            else
              error_count += 1
            end
          end
          @bench_test_photo_gen.good_count = good_count
          @bench_test_photo_gen.error_count = error_count
          @bench_test_photo_gen.result_message = "Test Complete."
        end
      end
    end
    if @bench_test_photo_gen.changed?
      # persist the changes
      @bench_test_photo_gen.save!
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bench_test_photo_gen }
    end
  end

  # GET /bench_test/photo_gens/new
  # GET /bench_test/photo_gens/new.xml
  def new
    @bench_test_photo_gen = BenchTest::PhotoGen.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bench_test_photo_gen }
    end
  end

  # GET /bench_test/photo_gens/1/edit
  def edit
    @bench_test_photo_gen = BenchTest::PhotoGen.find(params[:id])
  end

  # POST /bench_test/photo_gens
  # POST /bench_test/photo_gens.xml
  def create
    @bench_test_photo_gen = BenchTest::PhotoGen.new(params[:bench_test_photo_gen])

    # create the album and photos which kicks off the work to generate thumbs
    mark_as_starting @bench_test_photo_gen

    respond_to do |format|
      if @bench_test_photo_gen.save
        format.html { redirect_to(@bench_test_photo_gen, :notice => 'Photo gen was successfully created.') }
        format.xml  { render :xml => @bench_test_photo_gen, :status => :created, :location => @bench_test_photo_gen }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bench_test_photo_gen.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bench_test/photo_gens/1
  # PUT /bench_test/photo_gens/1.xml
  def update
    @bench_test_photo_gen = BenchTest::PhotoGen.find(params[:id])

    respond_to do |format|
      if @bench_test_photo_gen.update_attributes(params[:bench_test_photo_gen])
        format.html { redirect_to(@bench_test_photo_gen, :notice => 'Photo gen was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bench_test_photo_gen.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bench_test/photo_gens/1
  # DELETE /bench_test/photo_gens/1.xml
  def destroy
    @bench_test_photo_gen = BenchTest::PhotoGen.find(params[:id])
    @bench_test_photo_gen.destroy

    respond_to do |format|
      format.html { redirect_to(bench_test_photo_gens_url) }
      format.xml  { head :ok }
    end
  end

  # create the batch of work
  # by preparing the files to associate
  # and then assigning them to Photo objects
  # just the act of creation kicks off the
  # chain of related reduced size photo
  # generation events
  #
  def create_work data
    if current_user == false
      raise "You must be logged into a user account to run this test."
    end
    # append to album and photo dir
    rand_name = rand(999999999).to_s

    album = PersonalAlbum.new
    album.name = "Perf Test " + rand_name
    # tie album to current user
    current_user.albums << album
    album.save!
    data.album_id = album.id
    data.user_id = current_user.id

    # get info about prototype file
    name = "perftest.jpg"
    path = "#{Rails.root}/test/assets/"
    full_path = path + name
    file_size = File.size(full_path)
    data.file_size = file_size

    # now make the specified number of copies
    # in temp storage
    tmp_dir = Dir.tmpdir + "/perf-test/" + rand_name + "/"
    # NOTE: we don't track this temp dir so it will never get
    # deleted - the files themselves will be after the Photo
    # object is done with them
    `mkdir -p #{tmp_dir} 2>/dev/null`

    iterations = data.iterations

    # first pre-create the files to use
    for i in 1..iterations
      cmd = "cp #{full_path} #{tmp_dir}#{i} 2>/dev/null"
      `#{cmd}`
    end

    # now associate the files with photos
    attachments = []
    for i in 1..iterations
      src_file = "#{tmp_dir}#{i}"
      image = {
          "original_name" => i.to_s,
          "filepath" => src_file,
          "content_type" => "image/jpg"
      }
      attachments << image
    end
    # now add them all
    add_photos(album, current_user, attachments)

    data.save!
  end

  # take the incoming file attachments and make photos out of them
  def add_photos(album, user, attachments)
    if attachments.count > 0
      last_photo = nil
      photos = []
      current_batch = UploadBatch.get_current_and_touch( user.id, album.id )
      attachments.each do |fast_local_image|
        photo = Photo.new_for_batch(current_batch, {
                :id => Photo.get_next_id,
                :user_id => user.id,
                :album_id => album.id,
                :upload_batch_id => current_batch.id,
                :caption => fast_local_image["original_name"],
                #create random uuid for this photo
                :source_guid => "perftest:"+UUIDTools::UUID.random_create.to_s})
        # use the passed in temp file to attach to the photo
        #todo this doesn't actually do the right thing because a bulk insert does not write the child object photo_info
        photo.file_to_upload = fast_local_image['filepath']
        photos << photo
        last_photo = photo
      end

      # bulk insert
      Photo.batch_insert(photos)

      # this should remain since only used
      # for timing test an we want the batch closed
      # since they are grouped together
      last_photo.upload_batch.close_immediate
    end
  end

end
