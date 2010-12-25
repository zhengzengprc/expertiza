class StudentTaskController < ApplicationController
  helper :submitted_content
  
  def list
    if session[:user].is_new_user
      redirect_to :controller => 'eula', :action => 'display'
    end
    sortBy=params[:sort_by]
    if (session[:desc]==nil)
      session[:desc]=true
    end
    desc=!session[:desc];
    session[:desc]=desc;
    @participants = AssignmentParticipant.find(:all, :order=>"parent_id DESC", :conditions=>"user_id=#{session[:user].id}")

=begin
    the following is the critical part of the code that enables the sorting functionality.
    it uses rocket operator to initiate comparison, we use a case statement to do different sorting
    according to the criterio  we GET from the URL parameter. After the sorting, we pass @participants to
    the corresponding view page to display it.
=end

    case sortBy
      when "assignment"
        @participants.sort! { |a, b| a.assignment.name <=> b.assignment.name }
      when "topic"
        @participants.sort! { |a, b| a.get_topic_string <=> b.get_topic_string }
      when "course"
        @participants.sort! { |a, b| a.assignment.course.name <=> b.assignment.course.name }
      when "current_stage"
        @participants.sort! { |a, b| a.assignment.get_current_stage(a.topic_id) <=> b.assignment.get_current_stage(b.topic_id) }
      when "stage_deadline"
        @participants.sort! { |a, b| a.assignment.get_stage_deadline(a.topic_id) <=> b.assignment.get_stage_deadline(b.topic_id) }
      when "publishing_rights"
        @participants.sort! { |a, b| a.get_publishing_rights <=> b.get_publishing_rights }
    end
    if (desc)
      @participants.reverse!
    end


#    .find_all_by_user_id(session[:user].id, :order => "assignment.name DESC",join=>:assignment)
  end
  
  def view
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment    
    @can_provide_suggestions = Assignment.find(@assignment.id).allow_suggestions
    @reviewee_topic_id = nil
    #Even if one of the reviewee's work is ready for review "Other's work" link should be active
    if @assignment.staggered_deadline?
      if @assignment.team_assignment
        review_mappings = TeamReviewResponseMap.find_all_by_reviewer_id(@participant.id)
      else
        review_mappings = ParticipantReviewResponseMap.find_all_by_reviewer_id(@participant.id)
      end

      review_mappings.each { |review_mapping|
          if @assignment.team_assignment
            user_id = TeamsUser.find_all_by_team_id(review_mapping.reviewee_id)[0].user_id
            participant = Participant.find_by_user_id_and_parent_id(user_id,@assignment.id)
          else
            participant = Participant.find_by_id(review_mapping.reviewee_id)
          end

          if !participant.topic_id.nil?
            review_due_date = TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id,1)

            if review_due_date.due_at < Time.now && @assignment.get_current_stage(participant.topic_id) != 'Complete'
              @reviewee_topic_id = participant.topic_id
            end
          end
        }
    end
  end
  
  def others_work
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    # Finding the current phase that we are in
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment.id])
    @very_last_due_date = DueDate.find(:all,:order => "due_at DESC", :limit =>1, :conditions => ["assignment_id = ?",@assignment.id])
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < next_due_date.due_at
          next_due_date = due_date
        end
      end
    end
    
    @review_phase = next_due_date.deadline_type_id;
    if next_due_date.review_of_review_allowed_id == DueDate::LATE or next_due_date.review_of_review_allowed_id == DueDate::OK
      if @review_phase == DeadlineType.find_by_name("metareview").id
        @can_view_metareview = true
      end
    end    
    
    @review_mappings = ResponseMap.find_all_by_reviewer_id(@participant.id)
    @review_of_review_mappings = MetareviewResponseMap.find_all_by_reviewer_id(@participant.id)    
  end
  
  def your_work
    
  end
  

end
