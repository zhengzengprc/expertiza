class MicrotasksController < ApplicationController
  # GET /microtasks
  # GET /microtasks.xml
  def index
    #    render :text => "Hello World Anup"
    @microtasks = Microtask.find(:all)
  end

  def new
    #creating new Microtasks and setting default values using helper functions
    if params[:course_id]
      @course = Course.find(params[:course_id])
    end

    @microtask = Microtask.new
    #calling the defalut values mathods
    user_id = session[:user].id

  end

  def create

    #This sets the name parameter of the microtask,store the relevant fields.
    @microtask = Microtask.new(params[:microtask])
    #This sets the instructor_id parameter of the microtask
    @user =  ApplicationHelper::get_user_role(session[:user])
    @user = session[:user]
    @user.set_instructor(@microtask)
    #This sets the submitter_count field.
    @microtask.submitter_count = 0
    ## feedback added
    @microtask.require_signup = true
    ##

    if params[:days].nil? && params[:weeks].nil?
      @days = 0
      @weeks = 0
    elsif params[:days].nil?
      @days = 0
    elsif params[:weeks].nil?
      @weeks = 0
    else
      @days = params[:days].to_i
      @weeks = params[:weeks].to_i
    end

    # Deadline types used in the deadline_types DB table
    deadline = DeadlineType.find_by_name("submission")
    @Submission_deadline= deadline.id
    if @microtask.save

      flash[:notice] = 'microtask was successfully created.'
      #After successfully adding the task show the list of microtasks.
      redirect_to  :action => 'list_microtasks'
      #redirect_to :action => 'list', :controller => 'tree_display'

    else
      flash[:notice] = 'Could not  create  microtask'
      #redirect_to :action => 'list', :controller => 'tree_display'
      render :text =>"Something went wrong while doing microtask/create"
    end

  end

  # GET /microtasks/1/edit
  def edit
    @microtasks = Microtask.find(:all)
  end


  # DELETE /microtasks/1
  # DELETE /microtasks/1.xml
  def delete
    microtasks = Microtask.find_by_id(params[:id])
    flash[:notice] = "Microtask #{microtasks.name} was successfully deleted."
    #delete microtask participants before deleting the microtask.
    microtask_participants = MicrotaskParticipant.find(:all,:conditions => ["microtaskid=?",microtasks.id])
    microtask_participants.each do |participant|
      participant.destroy
    end

    microtasks.destroy
    redirect_to :action => 'edit'
  end

  def microtask
    @microtasks = Microtask.find(:all)
  end

  def subscribe
    @microtasks = Microtask.find(:all)
    puts "testing subscribe"

    if (params[:id] != nil)
      @user=session[:user]
      participant=MicrotaskParticipant.new
      participant.userid=@user.id
      participant.microtaskid=params[:id]
      available_slots=Microtask.get_slot(participant.microtaskid)
      if available_slots > 0
        participant.save
      else
        flash[:notice] = 'Slots not Available'
      end
    end
  end

  def work
    @user=session[:user]
    @pmicrotasks = MicrotaskParticipant.find(:all,:conditions => ["userid =?",@user.id])

  end

  def viewscore
    @user=session[:user]
    @pmicrotasks = MicrotaskParticipant.find(:all,:conditions => ["userid =?",@user.id])

  end

  def delete_microtask_participant
    if (params[:id] != nil)
      @user=session[:user]
      participant=MicrotaskParticipant.find_by_userid_and_microtaskid(@user.id,params[:id])
      participant.destroy
      params[:id] = nil
    end
    redirect_to :controller => 'microtasks' ,:action => 'subscribe'
  end

  def list_microtasks
    @microtasks = Microtask.find(:all)
  end

  def users_belonging_to_microtask

    @participants = MicrotaskParticipant.find(:all, :conditions => ["microtaskid =?", params[:id]]);
    #render :text => @participants.length
  end

  def update
    @microtask = Microtask.find_by_id(params[:id])

    #render :text =>"This should be easy"
    @microtask.update_attributes(params[:microtask])
    redirect_to :action => 'edit'
  end

  def list_microtask_to_update
    @microtask = Microtask.find_by_id(params[:id])
  end
  
end
