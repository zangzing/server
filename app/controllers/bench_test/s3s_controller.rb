class BenchTest::S3sController < BenchTest::BenchTestsController
  # GET /bench_test/s3s
  # GET /bench_test/s3s.xml
  def index
    @bench_test_s3s = BenchTest::S3.all

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
end
