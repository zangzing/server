class SharesController < ApplicationController
  # GET /shares/new
  # GET /shares/new.xml
  def new
    @share = Share.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @share }
    end
  end

  # POST /shares
  # POST /shares.xml
  def create
    @share = Share.new(params[:share])

    respond_to do |format|
      if @share.save
        flash[:notice] = 'Share was successfully created.'
        format.html { redirect_to(@share) }
        format.xml  { render :xml => @share, :status => :created, :location => @share }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @share.errors, :status => :unprocessable_entity }
      end
    end
  end
end
