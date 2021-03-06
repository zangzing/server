#
# Generated initially with
# rails generate scaffold BenchTest/S3 result_message:string start:datetime stop:datetime iterations:integer file_size:integer upload:boolean
#
class BenchTest::S3sController < BenchTest::BenchTestsController
  # GET /bench_test/s3s
  # GET /bench_test/s3s.xml
  def index
    @bench_test_s3s = BenchTest::S3.order("created_at DESC").limit(5)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bench_test_s3s }
    end
  end

  # GET /bench_test/s3s/1
  # GET /bench_test/s3s/1.xml
  def show
    @bench_test_s3 = BenchTest::S3.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bench_test_s3 }
    end
  end

  # GET /bench_test/s3s/new
  # GET /bench_test/s3s/new.xml
  def new
    @bench_test_s3 = BenchTest::S3.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bench_test_s3 }
    end
  end

  # GET /bench_test/s3s/1/edit
  def edit
    @bench_test_s3 = BenchTest::S3.find(params[:id])
  end

  # POST /bench_test/s3s
  # POST /bench_test/s3s.xml
  def create
    @bench_test_s3 = BenchTest::S3.new(params[:bench_test_s3])

    mark_as_starting @bench_test_s3


    respond_to do |format|
      if @bench_test_s3.save
        format.html { redirect_to(@bench_test_s3, :notice => 'S3 was successfully created.') }
        format.xml  { render :xml => @bench_test_s3, :status => :created, :location => @bench_test_s3 }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bench_test_s3.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bench_test/s3s/1
  # PUT /bench_test/s3s/1.xml
  def update
    @bench_test_s3 = BenchTest::S3.find(params[:id])

    respond_to do |format|
      if @bench_test_s3.update_attributes(params[:bench_test_s3])
        format.html { redirect_to(@bench_test_s3, :notice => 'S3 was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bench_test_s3.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bench_test/s3s/1
  # DELETE /bench_test/s3s/1.xml
  def destroy
    @bench_test_s3 = BenchTest::S3.find(params[:id])
    @bench_test_s3.destroy

    respond_to do |format|
      format.html { redirect_to(bench_test_s3s_url) }
      format.xml  { head :ok }
    end
  end

  def mark_as_starting data
    # validate stuff then pass on
    if data.file_size? == false
      data.file_size = 1000000 # default
    end
    if data.upload? == false
      data.upload = false
    end
    super(data)
  end

  def create_work data
    ZZ::Async::TestS3.enqueue data.id
  end

end
