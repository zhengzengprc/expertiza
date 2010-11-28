class VoluntaryWorksController < ApplicationController
  # GET /voluntary_work
  # GET /voluntary_work.xml
  def index
    @voluntary_works = VoluntaryWork.find(:all)
    @list_voluntary_works = VoluntaryWork.find_all_by_course_id(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @voluntary_works }
    end
  end

  # GET /voluntary_work/1
  # GET /voluntary_work/1.xml
  def show
    @voluntary_work = VoluntaryWork.find(params[:id])
    @list_voluntary_works = VoluntaryWork.find_all_by_course_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @voluntary_work }
    end
  end

  # GET /voluntary_work/new
  # GET /voluntary_work/new.xml
  def new
    @voluntary_work = VoluntaryWork.new
    @list_voluntary_works = VoluntaryWork.find_all_by_course_id(params[:id])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @voluntary_work }
    end
  end

  # GET /voluntary_work/1/edit
  def edit
    if params[:id] != nil then     
      @list_voluntary_works = VoluntaryWork.find_all_by_course_id(params[:id])
      @list_assignment = Assignment.find_all_by_course_id(params[:id])
      
      
      #Microtask logic
       @all_microtasks = Array.new
      for voluntary_work in @list_voluntary_works
        if voluntary_work.task_type == "microtask"
           @all_microtasks << voluntary_work
        end
      end
      
      #Assignment for xtra review logic
      @all_exta_review_tasks = Array.new
      for assignment in @list_assignment
          assignment_found = 0
          for voluntary_work in @list_voluntary_works
            if assignment.name == voluntary_work.name
              assignment_found = 1
              @all_exta_review_tasks << voluntary_work
            end
          end
          if assignment_found == 0
            assignment_for_review = VoluntaryWork.new
            assignment_for_review.name = assignment.name
            assignment_for_review.weight = 0
            assignment_for_review.course_id = assignment.course_id
            assignment_for_review.task_type = "assignment_for_extra_review"
            assignment_for_review.save
            @all_exta_review_tasks << assignment_for_review
         end

      end

      # Message board logic
      @message_board_task = Array.new
      message_board_found = 0
      for voluntary_work in @list_voluntary_works
         if voluntary_work.task_type == "message_board"
            message_board_found = 1
            @message_board_task << voluntary_work
         end
      end
      if message_board_found == 0
          message_board = VoluntaryWork.new
          message_board.name = "Message Board"
          message_board.weight = 0
          message_board.task_type = "message_board"
          message_board.course_id = params[:id]
          message_board.save
          @message_board_task << message_board
      end
      
    end
  end


  # PUT /voluntary_work/1
  # PUT /voluntary_work/1.xml
  def update
      params[:tasks].each_value do |task|
        @voluntary_work = VoluntaryWork.find(task["id"])
        @voluntary_work.update_attributes(task)
      end
      redirect_to :controller=> 'tree_display', :action=>'list'
  end

  # DELETE /voluntary_work/1
  # DELETE /voluntary_work/1.xml
  def destroy
    @voluntary_work = VoluntaryWork.find(params[:id])
    @voluntary_work.destroy

    respond_to do |format|
      format.html { redirect_to(voluntary_works_url) }
      format.xml  { head :ok }
    end
  end
  
  def calculate_score
  end

end
