class ResponseController < ApplicationController
  helper :wiki
  helper :submitted_content
  helper :file
  @@threshold=2
  def showGoodReview
    @responseMaps=nil
    @info=""
    @assignment=Assignment.find(params[:assignment])
    @similarAssignments=Assignment.find_by_sql("select * from assignments where keyword like '%"+@assignment.keyword+"%' and id!="+@assignment.id.to_s)
    if (@similarAssignments.size==0)
      @info="Failed to find similar assignment with keyword "+@assignment.keyword
    else
      @similarAssignment=@similarAssignments.first()
      @info+="I have found a similar assignment: "+@similarAssignment.name+"<br />";
      @responseMaps=ResponseMap.find_all_by_reviewed_object_id(@similarAssignment.id)
      @reviewNum=@responseMaps.size
      if (@reviewNum<@@threshold)
        @info+="I failed to find the good review because I need at lease "+@@threshold.to_s+" reviews."+"<br />";
        redirect_to :action => 'view', :msg => @info
#      
    else
      
      @maxAvg=0;
      @goodResponse=nil;
      if (@responseMaps!=nil) 
        @responseMaps.each {
          |rm|
          @aReview=Response.find_by_map_id(rm.id)
          if (!@aReview.nil?)
            @authorFeedbackAvg=getAuthorFeedbackAvg(@aReview)
            if (@authorFeedbackAvg>@maxAvg)
              @maxAvg=@authorFeedbackAvg
              @goodResponse=@aReview
            end
          end
        }
      end
      if (@goodResponse==nil)
        @info+="I have failed to finding a good review for you."+"<br />";
        redirect_to :action => 'view', :msg => @info
      else
        @info+="I have found a good review for you, it's a good review because it has the highest average author feedback score "
        @info+=" among "+ @reviewNum.to_s+" reviews"
        redirect_to :action => 'view', :id => @goodResponse.id, :msg => @info
      end
    end
  end
  
  
end


def getAuthorFeedbackAvg (aReview)
  if (aReview.nil?)
    return 0
  end
  @responseMaps=ResponseMap.find_all_by_reviewed_object_id(aReview.id)
  if (@responseMaps==nil)
    return 0;
  end
  @numOfReviewer=@responseMaps.size
  @totalScore=0
  @responseMaps.each {
    |rm|
    @aAuthorFeedback=Response.find_by_map_id(rm.id)
    @totalScore+=@aAuthorFeedback.get_total_score()
    
  }
  if (@numOfReviewer==0)
    return 0
  end
  return @totalScore/@numOfReviewer
end


def view
  @msg=params[:msg]
  if (params[:id]!=nil)
    @response = Response.find(params[:id])
    @map = @response.map
    
    get_content
  end
end

def delete
  @response = Response.find(params[:id])
  map_id = @response.map.id
  @response.delete
  redirect_to :action => 'redirection', :id => map_id, :return => params[:return], :msg => "The response was deleted."
end

def edit
  @header = "Edit"
  @next_action = "update"
  
  @return = params[:return]
  @response = Response.find(params[:id])
  @modified_object = @response.id
  @map = @response.map
  get_content
  @review_scores = Array.new
  @questions.each {
    |question|
    @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
  }
  render :action => 'response'
end

def update
  @response = Response.find(params[:id])
  @myid = @response.id
  msg = ""
  begin
    @myid = @response.id
    @map = @response.map
    @response.update_attribute('additional_comment', params[:review][:comments])
    
    @questionnaire = @map.questionnaire
    questions = @questionnaire.questions
    
    params[:responses].each_pair do |k, v|
      score = Score.find_by_response_id_and_question_id(@response.id, questions[k.to_i].id)
      score.update_attribute('score', v[:score])
      score.update_attribute('comments', v[:comment])
    end
  rescue
    msg = "Your response was not saved. Cause: "+ $!
  end
  
  begin
    ResponseHelper.compare_scores(@response, @questionnaire)
    ScoreCache.update_cache(@response.id)
    
    msg = "Your response was successfully saved."
  rescue
    msg = "An error occurred while saving the response: "+$!
  end
  redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
end

def new_feedback
  review = Response.find(params[:id])
  if review
    reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, review.map.assignment.id)
    map = FeedbackResponseMap.find_by_reviewed_object_id_and_reviewer_id(review.id, reviewer.id)
    if map.nil?
      map = FeedbackResponseMap.create(:reviewed_object_id => review.id, :reviewer_id => reviewer.id, :reviewee_id => review.map.reviewer.id)
    end
    redirect_to :action => 'new', :id => map.id, :return => "feedback"
  else
    redirect_to :back
  end
end

def new
  @header = "New"
  @next_action = "create"
  @feedback = params[:feedback]
  @map = ResponseMap.find(params[:id])
  @return = params[:return]
  @modified_object = @map.id
  get_content
  render :action => 'response'
end

def create
  @map = ResponseMap.find(params[:id])
  @res = 0
  msg = ""
  begin
    @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments])
    @res = @response.id
    @questionnaire = @map.questionnaire
    questions = @questionnaire.questions
    params[:responses].each_pair do |k, v|
      score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
    end
  rescue
    msg = "Your response was not saved. Cause: "+$!
  end
  
  begin
    ResponseHelper.compare_scores(@response, @questionnaire)
    ScoreCache.update_cache(@res)
    msg = "Your response was successfully saved."
  rescue
    @response.delete
    msg = "Your response was not saved. Cause: "+$!
  end
  redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
end

def saving
  @map = ResponseMap.find(params[:id])
  @return = params[:return]
  @msg = params[:msg]
end

def redirection
  @map = ResponseMap.find(params[:id])
  if params[:return] == "feedback"
    redirect_to :controller => 'grades', :action => 'view_my_scores', :id => @map.reviewer.id
  elsif params[:return] == "teammate"
    redirect_to :controller => 'student_team', :action => 'view', :id => @map.reviewer.id
  elsif params[:return] == "instructor"
    redirect_to :controller => 'grades', :action => 'view', :id => @map.assignment.id
  else
    redirect_to :controller => 'student_review', :action => 'list', :id => @map.reviewer.id
  end
end

private

def get_content
  @title = @map.get_title
  @assignment = @map.assignment
  @participant = @map.reviewer
  @contributor = @map.contributor
  @questionnaire = @map.questionnaire
  @questions = @questionnaire.questions
  @min = @questionnaire.min_question_score
  @max = @questionnaire.max_question_score
end

end