class BenchTest::ResqueNoOpsController < BenchTest::BenchTestsController

  # GET /bench_test/resque_no_ops
  # GET /bench_test/resque_no_ops.xml
  def index
    @bench_test_resque_no_ops = BenchTest::ResqueNoOp.order("created_at DESC").limit(5)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bench_test_resque_no_ops }
    end
  end

  # GET /bench_test/resque_no_ops/1
  # GET /bench_test/resque_no_ops/1.xml
  def show
    @bench_test_resque_no_op = BenchTest::ResqueNoOp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bench_test_resque_no_op }
    end
  end

  # GET /bench_test/resque_no_ops/new
  # GET /bench_test/resque_no_ops/new.xml
  def new
    @bench_test_resque_no_op = BenchTest::ResqueNoOp.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bench_test_resque_no_op }
    end
  end

  # GET /bench_test/resque_no_ops/1/edit
  def edit
    @bench_test_resque_no_op = BenchTest::ResqueNoOp.find(params[:id])
  end

  # POST /bench_test/resque_no_ops
  # POST /bench_test/resque_no_ops.xml
  def create
    @bench_test_resque_no_op = BenchTest::ResqueNoOp.new(params[:bench_test_resque_no_op])

    mark_as_starting @bench_test_resque_no_op

    respond_to do |format|
      if @bench_test_resque_no_op.save
        format.html { redirect_to(@bench_test_resque_no_op, :notice => 'Resque no op was successfully created.') }
        format.xml  { render :xml => @bench_test_resque_no_op, :status => :created, :location => @bench_test_resque_no_op }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bench_test_resque_no_op.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bench_test/resque_no_ops/1
  # PUT /bench_test/resque_no_ops/1.xml
  def update
    @bench_test_resque_no_op = BenchTest::ResqueNoOp.find(params[:id])

    respond_to do |format|
      if @bench_test_resque_no_op.update_attributes(params[:bench_test_resque_no_op])
        format.html { redirect_to(@bench_test_resque_no_op, :notice => 'Resque no op was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bench_test_resque_no_op.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bench_test/resque_no_ops/1
  # DELETE /bench_test/resque_no_ops/1.xml
  def destroy
    @bench_test_resque_no_op = BenchTest::ResqueNoOp.find(params[:id])
    @bench_test_resque_no_op.destroy

    respond_to do |format|
      format.html { redirect_to(bench_test_resque_no_ops_url) }
      format.xml  { head :ok }
    end
  end

  def create_work data
    iterations = data.iterations
    make_noop data, "start", 0
    for i in 1..iterations
      make_noop data, "noop", i
    end
    make_noop data, "stop", 0
  end

  def make_noop data, command, iterations
    ZZ::Async::TestNoop.enqueue data.id, command, iterations
  end

end
