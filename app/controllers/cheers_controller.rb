class CheersController < ApplicationController
    
  # GET /cheers
  # GET /cheers.xml
  def index
    @cheers = Cheer.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cheers }
    end
  end
  
  # GET /cheers/1
  # GET /cheers/1.xml
  def show
    @cheer = Cheer.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cheer }
    end
  end
  
  # GET /cheers/new
  # GET /cheers/new.xml
  def new
    @cheer = Cheer.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cheer }
    end
  end
  
  # GET /cheers/1/edit
  def edit
    @cheer = Cheer.find(params[:id])
  end
  
  # POST /cheers
  # POST /cheers.xml
  def create
    @cheer = Cheer.new(params[:cheer])
    
    respond_to do |format|
      if @cheer.save
        format.html { redirect_to(@cheer, :notice => 'Cheer was successfully created.') }
        format.xml  { render :xml => @cheer, :status => :created, :location => @cheer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cheer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /cheers/1
  # PUT /cheers/1.xml
  def update
    @cheer = Cheer.find(params[:id])
    
    respond_to do |format|
      if @cheer.update_attributes(params[:cheer])
        format.html { redirect_to(@cheer, :notice => 'Cheer was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cheer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /cheers/1
  # DELETE /cheers/1.xml
  def destroy
    @cheer = Cheer.find(params[:id])
    @cheer.destroy
    
    respond_to do |format|
      format.html { redirect_to(cheers_url) }
      format.xml  { head :ok }
    end
  end
end
