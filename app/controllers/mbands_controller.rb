class MbandsController < ApplicationController
  
  before_filter :login_required :except => [:index, :show]
  
  # GET /mbands
  # GET /mbands.xml
  def index
    @mbands = Mband.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mbands }
    end
  end

  # GET /mbands/1
  # GET /mbands/1.xml
  def show
    @mband = Mband.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mband }
    end
  end

  # GET /mbands/new
  # GET /mbands/new.xml
  def new
    @mband = Mband.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mband }
    end
  end

  # GET /mbands/1/edit
  def edit
    @mband = Mband.find(params[:id])
  end

  # POST /mbands
  # POST /mbands.xml
  def create
    @mband = Mband.new(params[:mband])

    respond_to do |format|
      if @mband.save
        flash[:notice] = 'Mband was successfully created.'
        format.html { redirect_to(@mband) }
        format.xml  { render :xml => @mband, :status => :created, :location => @mband }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mband.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mbands/1
  # PUT /mbands/1.xml
  def update
    @mband = Mband.find(params[:id])

    respond_to do |format|
      if @mband.update_attributes(params[:mband])
        flash[:notice] = 'Mband was successfully updated.'
        format.html { redirect_to(@mband) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mband.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mbands/1
  # DELETE /mbands/1.xml
  def destroy
    @mband = Mband.find(params[:id])
    @mband.destroy

    respond_to do |format|
      format.html { redirect_to(mbands_url) }
      format.xml  { head :ok }
    end
  end
end
