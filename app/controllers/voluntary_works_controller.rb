class VoluntaryWorksController < ApplicationController
  # GET /voluntary_works
  # GET /voluntary_works.xml
  def index
    @voluntary_works = VoluntaryWork.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @voluntary_works }
    end
  end

  # GET /voluntary_works/1
  # GET /voluntary_works/1.xml
  def show
    @voluntary_work = VoluntaryWork.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @voluntary_work }
    end
  end

  # GET /voluntary_works/new
  # GET /voluntary_works/new.xml
  def new
    @voluntary_work = VoluntaryWork.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @voluntary_work }
    end
  end

  # GET /voluntary_works/1/edit
  def edit
    @voluntary_work = VoluntaryWork.find(params[:id])
  end

  # POST /voluntary_works
  # POST /voluntary_works.xml
  def create
    @voluntary_work = VoluntaryWork.new(params[:voluntary_work])

    respond_to do |format|
      if @voluntary_work.save
        flash[:notice] = 'VoluntaryWork was successfully created.'
        format.html { redirect_to(@voluntary_work) }
        format.xml  { render :xml => @voluntary_work, :status => :created, :location => @voluntary_work }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @voluntary_work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /voluntary_works/1
  # PUT /voluntary_works/1.xml
  def update
    @voluntary_work = VoluntaryWork.find(params[:id])

    respond_to do |format|
      if @voluntary_work.update_attributes(params[:voluntary_work])
        flash[:notice] = 'VoluntaryWork was successfully updated.'
        format.html { redirect_to(@voluntary_work) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voluntary_work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /voluntary_works/1
  # DELETE /voluntary_works/1.xml
  def destroy
    @voluntary_work = VoluntaryWork.find(params[:id])
    @voluntary_work.destroy

    respond_to do |format|
      format.html { redirect_to(voluntary_works_url) }
      format.xml  { head :ok }
    end
  end
end
