class MicrotaskParticipantsController < ApplicationController
    def index
    @microtask_participants = MicrotaskParticipants.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @microtask_participants }
    end
  end

  # GET /microtask_participants/1
  # GET /microtask_participants/1.xml
  def show
    @microtask_participants = MicrotaskParticipants.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @microtask_participants }
    end
  end

  # GET /microtask_participants/new
  # GET /microtask_participants/new.xml
  def new
    @microtask_participants = MicrotaskParticipants.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @microtask_participants }
    end
  end

  # GET /microtask_participants/1/edit
  def edit
    @microtask_participants = MicrotaskParticipants.find(params[:id])
  end

  # POST /microtask_participants
  # POST /microtask_participants.xml
  def create
    @microtask_participants = MicrotaskParticipants.new(params[:microtask_participants])

    respond_to do |format|
      if @microtask_participants.save
        flash[:notice] = 'MicrotaskParticipants was successfully created.'
        format.html { redirect_to(@microtask_participants) }
        format.xml  { render :xml => @microtask_participants, :status => :created, :location => @microtask_participants }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @microtask_participants.errors, :status => :unprocessable_entity }
      end
    end
  end


  # PUT /microtask_participants/1.xml
  def update
    @microtask_participants = MicrotaskParticipants.find(params[:id])

    respond_to do |format|
      if @microtask_participants.update_attributes(params[:microtask_participants])
        flash[:notice] = 'MicrotaskParticipants was successfully updated.'
        format.html { redirect_to(@microtask_participants) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @microtask_participants.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /microtask_participants/1.xml
  def destroy
    @microtask_participants = MicrotaskParticipants.find(params[:id])
    @microtask_participants.destroy

    respond_to do |format|
      format.html { redirect_to(microtask_participants_url) }
      format.xml  { head :ok }
    end
  end
  
  def change_grade
    
      #With the below Query I will get unique entry in microtask_participant for which the grade needs to
      @micro_participant = MicrotaskParticipant.find(:all, :conditions =>["id =? ", params[:id]])
        if(params[:grade].to_i < 0 )
          @micro_participant[0].grades = 0
        elsif(params[:grade].to_i > 100)
          @micro_participant[0].grades = 100
        else
          @micro_participant[0].grades = params[:grade]
        end
        
        #saving grades
        @micro_participant[0].save
        redirect_to :controller =>'microtasks', :action =>'users_belonging_to_microtask', :id=> params[:microtask_id]
        #render :text => "Hello World"
  end
  
  
end
