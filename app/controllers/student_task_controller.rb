class StudentTaskController < ApplicationController
  helper :submitted_content
  
  def list
    if session[:user].is_new_user
      redirect_to :controller => 'eula', :action => 'display'
    end
    @participants = AssignmentParticipant.find_all_by_user_id(session[:user].id, :order => "parent_id DESC")
    # E03 task list functionality
    # call get task function to get tasks for logged in student    
    get_tasks(@participants)
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

  # E03 task list functionality
  # method to get all the tasks for logged in user
  def get_tasks(participants)
    @tasks=[]
    @tasks_name=Hash.new
    @author_feedback=Hash.new
    @active_link=Hash.new
    @waitlist_flag=Hash.new

	# get user preference for completed tasks
    curruser = session[:user]
    grayed = TaskGray.find_by_userid(curruser.id)
    if(grayed==nil or grayed==0 )
      @showgrayed = 0
    else
      @showgrayed = grayed.grayed
    end
    
    #check all the assignments for the user
    for participant in participants

         # get no of days to show completed tasks
         @crs = Course.find_by_id(participant.assignment.course_id)
          if @crs
            @link_timeout = @crs.cdate
          else
            @link_timeout=14
          end

         # get number of review rounds and based on rounds get last resubmission due date
          review_rounds = participant.assignment.get_review_rounds
          if !participant.assignment.staggered_deadline?
             if review_rounds>1
                final_resubmission_date=DueDate.find(:first, :conditions => ['assignment_id = ? and deadline_type_id = ? and round=?',participant.assignment.id,DeadlineType.find_by_name('resubmission').id, review_rounds])
             else
                 final_resubmission_date=DueDate.find(:first, :conditions => ['assignment_id = ? and deadline_type_id = ? ',participant.assignment.id,DeadlineType.find_by_name('review').id])
             end
          else
            if review_rounds>1
               final_resubmission_date=TopicDeadline.find_by_topic_id_and_deadline_type_id_and_round_id(participant.topic_id,DeadlineType.find_by_name('resubmission').id,review_rounds)
            else
              final_resubmission_date= TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id,DeadlineType.find_by_name('review').id)
            end
          end

          # get latest submitted date/time for this assignment
          submitted_at=get_submission_time(participant)

          # if submitted time is not there and there is no hyperlink submission then check for signup and submission
          if submitted_at.nil?  and participant.get_hyperlinks.size == 0

             #check if an assignment has a signup sheet
            if SignUpTopic.find_by_assignment_id(participant.assignment.id)
                    #Find whether the user has signed up for any topics,
                    #if team assignment, then team id needs to be passed as parameter else the user's id
                   if participant.assignment.team_assignment == true
                      users_team = SignedUpUser.find_team_users(participant.assignment.id,(session[:user].id))
                      if users_team.size == 0
                          user_signup = nil
                      else
                          user_signup = SignedUpUser.find_user_signup_topics(participant.assignment.id,users_team[0].t_id)
                      end
                  else
                      user_signup = SignedUpUser.find_user_signup_topics(participant.assignment.id,session[:user].id)
                  end

                  if !user_signup.nil? && user_signup.size != 0
                      for topic in user_signup
                          if(topic.is_waitlisted) # check if user has signed up as waitlised 
                              @waitlist_flag[(participant.assignment.id.to_s+'-signup').to_sym] =true
                          else
                              @waitlist_flag[(participant.assignment.id.to_s+'-signup').to_sym] =false
                          end
                      end
                  elsif participant.assignment.check_condition("submission_allowed_id",participant.topic_id) #  suer has nt sign up for topic if submission is allowed then show sign up link
                          @tasks<<participant
                          @tasks_name[(participant.assignment.id.to_s+'-signup').to_sym] = true
                          @active_link[(participant.assignment.id.to_s+'-signup').to_sym] = true
                  end
            end

            # no submission , check if sign up task is pending or nt, if nt then show submission as pending
            if  @tasks_name[(participant.assignment.id.to_s+'-signup').to_sym].nil? and (participant.assignment.get_current_stage(participant.topic_id)=='submission' or participant.assignment.check_condition("submission_allowed_id",participant.topic_id))
             
              @tasks<<participant
              @tasks_name[(participant.assignment.id.to_s+'-submission').to_sym] = true
              @active_link[(participant.assignment.id.to_s+'-submission').to_sym] = true
            end
        else
            # check for user preferences and set task for completed submission
            # check if completed task has to be shown and if timeout has nt been passed
            if @showgrayed==1 and (find_stage_deadline(participant,"submission").due_at+( @link_timeout*24*60*60) > Time.now)

              @tasks<<participant
              @tasks_name[(participant.assignment.id.to_s+'-submission').to_sym] = true
              @active_link[(participant.assignment.id.to_s+'-submission').to_sym] = false
              

            end
            
            #now check for resubmission
            if  review_rounds>1
              reviews= get_feedback_for_own_work(participant)  # get reviews given for self submission
              pending_rs=false     # check if review date is later than submission date, if yes then set pending resubmission as true
              if submitted_at
                for review in reviews
                  if review.updated_at and review.updated_at > submitted_at
                     pending_rs=true
                  end
                end
              end  
              # if resubmission is allowed and pending then add task to the list
              if pending_rs and  participant.assignment.check_condition("resubmission_allowed_id",participant.topic_id)
                  @tasks<<participant
                  @tasks_name[(participant.assignment.id.to_s+'-resubmission').to_sym] = true
                  @active_link[(participant.assignment.id.to_s+'-resubmission').to_sym] = true
			  elsif (find_stage_deadline(participant,"resubmission").due_at+( @link_timeout*24*60*60) > Time.now) and !pending_rs and reviews.size>0  # check if completed task has to be shown and if timeout has nt been passed
				 
                  @tasks<<participant
                  @tasks_name[(participant.assignment.id.to_s+'-resubmission').to_sym] = true
                  @active_link[(participant.assignment.id.to_s+'-resubmission').to_sym] = false

              end

            end
          end
            # get reviews to be done by logged in stduent for this assignment
             review_mappings=get_review_mappings(participant)
             pending_reviews=pending_reviews(review_mappings)  # check if reviews are pending
             if pending_reviews and participant.assignment.check_condition("review_allowed_id",participant.topic_id) # if pending and reviews are allowed then add to the task list
                    @tasks<<participant
                    @tasks_name[(participant.assignment.id.to_s+'-review').to_sym] = true
                    @active_link[(participant.assignment.id.to_s+'-review').to_sym] = true
             elsif review_mappings and review_mappings.size>0 and !pending_reviews  and (find_stage_deadline(participant,"review").due_at+( @link_timeout*24*60*60) > Time.now)

                    # check for user preferences and set task for completed review
                   # if review deadline has not yet passed, show this task as grayed
                    @tasks<<participant
                    @tasks_name[(participant.assignment.id.to_s+'-review').to_sym] = true
                    @active_link[(participant.assignment.id.to_s+'-review').to_sym] = false

             end

           if review_rounds>1   # check for rereview task
             pending_rereviews=pending_rereviews(review_mappings,participant)  # check if pending reviews are there

             if pending_rereviews and participant.assignment.check_condition("rereview_allowed_id",participant.topic_id)
                    @tasks<<participant
                    @tasks_name[(participant.assignment.id.to_s+'-rereview').to_sym] = true
                    @active_link[(participant.assignment.id.to_s+'-rereview').to_sym] = true
             elsif review_mappings and review_mappings.size>0 and !pending_rereviews and participant.assignment.get_current_stage(participant.topic_id)!='review' and (find_stage_deadline(participant,"rereview").due_at+( @link_timeout*24*60*60) > Time.now)  
                     # check for user preferences and set task for completed rereview
                     # if Re-review deadline has not yet passed, show this task as grayed

                     @tasks<<participant
                     @tasks_name[(participant.assignment.id.to_s+'-rereview').to_sym] = true
                     @active_link[(participant.assignment.id.to_s+'-rereview').to_sym] = false
             end
          end

           if participant.assignment.team_assignment and participant.team #if assignment is team based then check for teammate review
             pending_tr=false

             for member in participant.team.get_participants  # check if reviews are pending for teammates 
               if participant.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire') != nil and member.user.id != session[:user].id
                     map = TeammateReviewResponseMap.find(:first, :conditions => ['reviewer_id = ? and reviewee_id = ?',participant.id, member.id])
                     if map.nil?
                       map = TeammateReviewResponseMap.create(:reviewer_id => participant.id, :reviewee_id => member.id, :reviewed_object_id => participant.assignment.id)
                     end
                     review = map.response  # if any response is nt there, then set pending flag as true
                     if review.nil?
                       pending_tr=true
                       break
                     end
               end
             end
            
             if pending_tr and ((Time.now - final_resubmission_date.due_at)/(60*60*24)<=7)  # if teammate review is pending and 1 week is there from final resubmission then show task
                # interim measure, should be replaced by actual teammate review deadline
                      @tasks<<participant
                      @tasks_name[(participant.assignment.id.to_s+'-teammate review').to_sym] = true
                      @active_link[(participant.assignment.id.to_s+'-teammate review').to_sym] = true

             elsif participant.team.get_participants.size>1 and !pending_tr and final_resubmission_date.due_at+( @link_timeout*24*60*60) > Time.now
                     # check for user preferences and set task for completed team mate review
                     # if Team-mate review deadline has not yet passed, show this task as grayed

                     @tasks<<participant
                     @tasks_name[(participant.assignment.id.to_s+'-teammate review').to_sym] = true
                     @active_link[(participant.assignment.id.to_s+'-teammate review').to_sym] = false
                     
             end
             
             
           end

           if Time.now < final_resubmission_date.due_at #check for author feedback, if final resubmission date has nt been passed
               reviews= get_feedback_for_own_work(participant)
               pending_af=false
               if reviews
                 for review in reviews   # get allr eviews and check if feedback for any review is pending
                   map = FeedbackResponseMap.find_by_reviewed_object_id(review.id)
                   if map.nil? or map.response.nil?
                     pending_af=true
                   end
                 end
               end

               if pending_af  # if pending author feedback then add task to the task list
                      @tasks<<participant
                      @tasks_name[(participant.assignment.id.to_s+'-author feedback').to_sym] = true
                      @active_link[(participant.assignment.id.to_s+'-author feedback').to_sym] = true
               elsif final_resubmission_date.due_at+( @link_timeout*24*60*60) > Time.now
                        # check for user preferences and set task for completed team mate review
                        # if Author feedback deadline (Final Submission deadline) has not yet passed, show this task as grayed
                        if(!reviews.blank?)
                              @tasks<<participant
                              @tasks_name[(participant.assignment.id.to_s+'-author feedback').to_sym] = true
                              @active_link[(participant.assignment.id.to_s+'-author feedback').to_sym] = false
                        end 
               end

           end

           # check for meta review
           if participant.assignment.check_condition("review_of_review_allowed_id",participant.topic_id)  or participant.assignment.get_current_stage() == "Complete"
              if !participant.topic_id.nil?
                 if review_rounds == 1
                    deadline_type_id = DeadlineType.find_by_name('review').id
                  else
                    deadline_type_id = DeadlineType.find_by_name('rereview').id        
                  end
                  meta_review_due_date = TopicDeadline.find_by_topic_id_and_deadline_type_id_and_round(participant.topic_id,deadline_type_id,review_rounds) # get meta review due date
                  if meta_review_due_date.nil?
                    meta_review_due_date = DueDate.find_by_assignment_id_and_deadline_type_id(participant.assignment.id,DeadlineType.find_by_name('metareview').id)
                  end
                  if meta_review_due_date.due_at < Time.now
                          @meta_reviewee_topic_id = participant.topic_id
                  end
               end

               if participant.assignment.metareview_allowed(@meta_reviewee_topic_id) or participant.assignment.get_current_stage() == "Complete"   # if meta review allowed then get meta review mapping
                    metareview_mappings = MetareviewResponseMap.find_all_by_reviewer_id(participant.id)

                    pending_mr=false;
                    metareview_mappings.each { |map|
                        pending_mr=true unless map.response
                     }

                    if pending_mr   # if meta review is pending  add task to the list
                      @tasks<<participant
                      @tasks_name[(participant.assignment.id.to_s+'-metareview').to_sym] = true                      
                      @active_link[(participant.assignment.id.to_s+'-metareview').to_sym] = true
                    elsif  metareview_mappings.size>0 and find_stage_deadline(participant,"metareview").due_at+( @link_timeout*24*60*60) > Time.now
                         # check for user preferences and set task for completed meta review

                        # if Meta-review deadline has not yet passed, show this task as grayed
                        @tasks<<participant
                        @tasks_name[(participant.assignment.id.to_s+'-metareview').to_sym] = true
                        @active_link[(participant.assignment.id.to_s+'-metareview').to_sym] = false
                    end
               end
           end
       end
   # sort task based on stage deadline of the assignment
   @tasks.sort! { |a,b|  a.assignment.get_stage_deadline(a.topic_id)<=> b.assignment.get_stage_deadline(b.topic_id) }
  end

  # function to get review mapping for  the assignment
  def get_review_mappings(participant)

    if participant.assignment.review_allowed(participant.topic_id) or participant.assignment.get_current_stage() == "Complete"

         if participant.assignment.team_assignment
            review_mappings = TeamReviewResponseMap.find_all_by_reviewer_id(participant.id)
         else
            review_mappings = ParticipantReviewResponseMap.find_all_by_reviewer_id(participant.id)
         end

    end
    review_mappings 

  end

  # function to check pending review for loggged in student
  def pending_reviews(review_mappings)
    flag=false
    if review_mappings
          review_mappings.each { |map|
              flag=true unless map.response
           }
    end
   flag 
  end

# function to check pending rereviews for loggged in student  
  def pending_rereviews(review_mappings,participant)
    flag=false
    if review_mappings
       review_mappings.each { |map|
       if participant.assignment.team_assignment
             team_user=TeamsUser.find(:first, :conditions => ["team_id =?",map.reviewee_id])
             reviewee= Participant.find(:first, :conditions =>["parent_id=? and user_id=?",participant.assignment.id,team_user.user_id])
       else
             reviewee=Participant.find(map.reviewee_id)
       end
       submitted_at=get_submission_time(reviewee)
       if map.response and submitted_at and map.response.updated_at<submitted_at
          flag=true
       end
     }

    end
    flag
  end

  # function to get reviews feedback for self submission 
  def get_feedback_for_own_work(participant)
     questions = Hash.new
     questionnaires = participant.assignment.questionnaires
     questionnaires.each{
        |questionnaire|
        questions[questionnaire.symbol] = questionnaire.questions
      }

     if participant.get_scores(questions)[:review]
      reviews= participant.get_scores(questions)[:review][:assessments]
     end  
     
  end

  # function to get latest submitted time for the asisgnment
  def get_submission_time(participant)
    submitted_at=ResubmissionTime.find(:first, :conditions => ['participant_id = ? ',participant.id], :order => "resubmitted_at DESC")
    if participant.assignment.team_assignment
      if participant.team
        participant.team.get_participants.each{
            | member |
            temp=ResubmissionTime.find(:first, :conditions => ['participant_id = ? ',member.id], :order => "resubmitted_at DESC")
            if submitted_at.nil? or (temp and submitted_at.resubmitted_at<temp.resubmitted_at)
                submitted_at=temp
            end
        }
      end
    end
    if submitted_at
      submitted_at.resubmitted_at
    else
      nil
    end
  end

  # function to  get the stage deadline of the given stage of the assignment
  def find_stage_deadline(participant,stage)
    if participant.assignment.staggered_deadline?
          due_dates = TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id,DeadlineType.find_by_name(stage).id)
        else
          due_dates = DueDate.find(:first, :conditions => ['assignment_id = ? and deadline_type_id = ? ',participant.assignment.id,DeadlineType.find_by_name(stage).id])
        end

  end

end

