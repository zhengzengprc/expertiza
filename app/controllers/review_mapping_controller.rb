class ReviewMappingController < ApplicationController
  auto_complete_for :user, :name
  use_google_charts
  
  def auto_complete_for_user_name
    name = params[:user][:name]+"%"
    assignment_id = session[:contributor].parent_id
    @users = User.find(:all, :include => :participants, 
      :conditions => ['participants.type = "AssignmentParticipant" and users.name like ? and participants.parent_id = ?',name,assignment_id], 
      :order => 'name') 

    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end
  
  def select_reviewer
    assignment = Assignment.find(params[:id])     
    @contributor = assignment.get_contributor(params[:contributor_id])
    session[:contributor] = @contributor

   assignment.questionnaires.each do |a|
       if a.display_type == "Review"
      @questionnaire = a
        end
  end
  @is_static = Questionnaire.find(@questionnaire.id)
  
    if(@is_static.is_static == 0)
    flash[:error] = "This assignment has a dynamic review. Cannot add a reviewer statically... "
    redirect_to :action => 'list_mappings', :id => params[:id]
    return
    end
  end
  
  def select_metareviewer
    @mapping = ResponseMap.find(params[:id])    
  end  
  
  # Author: Raghu Krishnamurthy and Shraddha Krishnamurthy
  def add_reviewer 
    assignment = Assignment.find(params[:id])  
    msg = String.new
    begin
      user = get_user(params)      
      regurl = url_for :action => 'add_user_to_assignment', 
          :id => assignment.id, 
          :user_id => user.id, 
          :contributor_id => params[:contributor_id]                     
      reviewer = get_reviewer(user,assignment,regurl)
      
      if assignment.team_assignment
        if TeamReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?',params[:id],reviewer.id]).nil?
          TeamReviewResponseMap.create(:reviewee_id => params[:contributor_id], :reviewer_id => reviewer.id, :reviewed_object_id => assignment.id)
        else
          raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      else
        if ParticipantReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?',params[:id],reviewer.id]).nil?
           ParticipantReviewResponseMap.create(:reviewee_id => params[:contributor_id], :reviewer_id => reviewer.id, :reviewed_object_id => assignment.id)
        else
           raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      end
    rescue
       msg = $!
    end    
    redirect_to :action => 'list_mappings', :id => assignment.id, :msg => msg    
  end
  
  def allow_same_topic_enabled(assignment)
      assignment.questionnaires.each do |a|
      if a.display_type == "Review"
      @questionnaire_topic = a
      end
      end
  @is_allow_sametopic = Questionnaire.find(@questionnaire_topic.id)
  if (@is_allow_sametopic.review_selection_type == "all_review_same_topic")
      return true
  else
      return false
  end
end


 def allow_different_topic_enabled(assignment)
      assignment.questionnaires.each do |a|
      if a.display_type == "Review"
      @questionnaire_topic = a
      end
      end
  @is_allow_sametopic = Questionnaire.find(@questionnaire_topic.id)
  if (@is_allow_sametopic.review_selection_type == "not_review_same_topic")
      return true
  else
      return false
  end
  end
  
  
  ## Lets the reviewer choose only from topics that he has previously chosen a review from
  def allow_same_topic(assignment, reviewer_id, topic_identifier)
    
    @is_first = ResponseMap.find_by_reviewed_object_id_and_reviewer_id(assignment.id,reviewer_id)
    if (@is_first.nil?)##First review for that assignmet, so can select any topic
      return true
    else
      if assignment.team_assignment ## If team assignment we have team id
        
        @team = Team.find(@is_first.reviewee_id)
        @team_user = TeamsUser.find_by_team_id(@team.id).user_id
        @participant_user = Participant.find_by_parent_id_and_user_id(assignment.id,@team_user)
        @topic_id = @participant_user.topic_id
        
        if (@topic_id.to_i == topic_identifier.to_i)
            return true
        else
            return false
        end
      else  ##Not team assignment we have participant id
        
       @participant_rev = Participant.find(@is_first.reviewee_id).topic_id
       if (@participant_rev.to_i == topic_identifier.to_i)
            return true
        else
            return false
        end
      end
      
    end
  end
  
  ## Reviewers should not be able to review from topics that have worked on
  
  def review_different_topic(participant, topic_identifier)
    
    @rev_participant  = Participant.find(participant.to_i).topic_id
  
    if !(@rev_participant.nil?)
     
      if (@rev_participant.to_i == topic_identifier.to_i )
       
        return false
      else
       
        return true
      end
    end
    return true
  end
  
  
  # Author: Raghu Krishnamurthy and Shraddha Krishnamurthy
  
  def add_dynamic_reviewer
    

    assignment = Assignment.find(params[:id]) 
      
    if(!params[:topic_id].nil?)###enter here only if there is a signup sheet. If not it should be nil
    
    if (allow_same_topic_enabled(assignment))
      
      flag = allow_same_topic(assignment,params[:participant_id],params[:topic_id])
      
          if (!flag)
            flash[:error] = "Please select the topic you have already selected."
            redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
            return
        end
      end
    
    if(allow_different_topic_enabled(assignment))
    
    flag = review_different_topic(params[:participant_id], params[:topic_id])
    
    if (!flag)
            flash[:error] = "You are not permitted to select your own topic to review ."
            redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
            return
        end
    
   end
   
      if(assignment.team_assignment)##handling team assingments.
        @team_names = SignedUpUser.find_all_by_topic_id(params[:topic_id])
        @teamname = Array.new
        @team_names.each do |name|
          @teamname << Team.find_by_id_and_parent_id(name.creator_id, assignment.id)
        end##End do 
        
        if @team_names.size == 0
           flash[:error] = "Sorry! Nobody has signed up for this topic Please pick another one."
          redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
          return
        end##end @team_names.size
        min = -1
        id = -1
        alternate_id = -1
        alternate_array = Array.new               
        @teamname.each do |t|
         
          @num_of_reviews = TeamReviewResponseMap.find_all_by_reviewed_object_id_and_reviewee_id(assignment.id,t.id)
          
          if min == -1
            min = @num_of_reviews.size
          elsif @num_of_reviews.size <= min
            min = @num_of_reviews.size
         end##end if elsif elsif
         end##end @teamname.each do
           
        @teamname.each do |t|
        @num_of_reviews = TeamReviewResponseMap.find_all_by_reviewed_object_id_and_reviewee_id(assignment.id,t.id)
        if @num_of_reviews.size == min
          alternate_array << t.id
        end
      end

           
        @user_id = Participant.find_by_id_and_parent_id(params[:participant_id],assignment.id).user_id
        @teamnames_topic = Team.find_all_by_parent_id(assignment.id)
        @teamnames_topic.each do |team|
          
           if(TeamsUser.find_by_team_id_and_user_id(team.id,@user_id))
           @team_id_topic = TeamsUser.find_by_team_id_and_user_id(team.id,@user_id)
           end #end if(TeamsUser...)
               
        end##end @teamnames_topic.each
           
             alternate_array.each do |a|
             @already_exists = TeamReviewResponseMap.find_by_reviewer_id_and_reviewee_id(params[:participant_id],a)
             if(@already_exists.nil? && @team_id_topic.team_id.to_i != a.to_i)
                 alternate_id = a
                 break
             end
         end
         
         
        if(params[:contributor_id].nil?)
           
          if(alternate_id != -1)
            params[:contributor_id]=alternate_id
          else
            flash[:error] = "Cannot assign any submission in this topic because only your submission has least reviews"
            redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
            return
            end
               
        end###if(id!= -1 && params[:contributor_id].nil?)

      else###Handling Non team assignments.
      
       @topic_participants = Participant.find_all_by_parent_id_and_topic_id(assignment.id,params[:topic_id])
       min = -1
       id = -1
       alternate_id = -1
       alternate_array = Array.new       
       @topic_participants.each do |t|
         @num_of_reviews = ParticipantReviewResponseMap.find_all_by_reviewed_object_id_and_reviewee_id(assignment.id,t.id)
         
         if min == -1
           min = @num_of_reviews.size
         elsif @num_of_reviews.size <= min
           min = @num_of_reviews.size
          end##end if elsif elsif
       end ##end @topic_participant.each do
  
      @topic_participants.each do |t|
        @num_of_reviews = ParticipantReviewResponseMap.find_all_by_reviewed_object_id_and_reviewee_id(assignment.id,t.id)
        if @num_of_reviews.size == min
          alternate_array << t.id
        end
      end
  
             alternate_array.each do |a|
             @already_exists = ParticipantReviewResponseMap.find_by_reviewer_id_and_reviewee_id(params[:participant_id],a)
             if(@already_exists.nil? && params[:participant_id].to_i != a.to_i)
                 alternate_id = a
                 break
             end
           end
       

       if(params[:contributor_id].nil?)
          if(alternate_id != -1)
            params[:contributor_id]=alternate_id
          else
            flash[:error] = "Cannot assign any submission in this topic because only your submission has least reviews change description"
            redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
            return
            end               
       end###if(id!= -1 && params[:contributor_id].nil?)  
      end##End IF team_assignment
    else
#      flash[:error] = "Pick Some Topic"
#      redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
#      return
    end
    
    
 ##########################################################################################
###########################################################################################
       if (params[:topic_id].nil? && params[:contributor_id].nil?)
      flash[:error] = "Please select atleast one option"
            redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
            return
    end
    
    assignment = Assignment.find(params[:id])
    
    
    if (assignment.sign_up_topics.size!=0 && params[:topic_id].nil? && !(params[:tid].nil?))
    if (allow_same_topic_enabled(assignment))
      
      flag = allow_same_topic(assignment,params[:participant_id],params[:tid])
      
          if (!flag)
            flash[:error] = "Please select a submission from the same topic you have already selected."
            redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
            return
        end
      end
    
    if(allow_different_topic_enabled(assignment))
    
    flag = review_different_topic(params[:participant_id], params[:tid])
    
    if (!flag)
            flash[:error] = "You are not permitted to select a submission to review from the same topic you have worked on."
            redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
            return
        end
    
   end
   
    end
    msg = String.new
    begin
      
      user = get_user(params)      
      regurl = url_for :action => 'add_user_to_assignment', 
          :id => assignment.id, 
          :user_id => user.id, 
          :contributor_id => params[:contributor_id]                     
      reviewer = get_reviewer(user,assignment,regurl)
       
      
      if assignment.team_assignment
       
        @user_id = Participant.find_by_id_and_parent_id(params[:participant_id],assignment.id).user_id
        @teamnames = Team.find_all_by_parent_id(assignment.id)
       
        @teamnames.each do |team|
           
           if(TeamsUser.find_by_team_id_and_user_id(team.id,@user_id))
           @team_id = TeamsUser.find_by_team_id_and_user_id(team.id,@user_id)
           end
               
        end
        
       if !(@team_id.nil?)      
       if( params[:contributor_id].to_i == @team_id.team_id)
       flash[:error] = "You have selected your own submission.Please select another submission"
       redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
       return
     end
     end
        if TeamReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?',params[:contributor_id],reviewer.id]).nil?
          TeamReviewResponseMap.create(:reviewee_id => params[:contributor_id], :reviewer_id => reviewer.id, :reviewed_object_id => assignment.id)
          if(!params[:topic_id].nil?)
            @topic=SignUpTopic.find(params[:topic_id])
            @topic.no_of_reviews += 1
            @topic.save
          end
          @team_review_count = Team.find(params[:contributor_id])
          @team_review_count.number_of_assigned_reviews +=1
          @team_review_count.save
          
        else
          flash[:error] = "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      else
       
       
       if(params[:contributor_id]==params[:participant_id])
       flash[:error] = "You have selected your own submission.Please select another submission"
       redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]
       return
     end
            
        if ParticipantReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?',params[:contributor_id],reviewer.id]).nil?
           ParticipantReviewResponseMap.create(:reviewee_id => params[:contributor_id], :reviewer_id => reviewer.id, :reviewed_object_id => assignment.id)
           if(!params[:topic_id].nil?)
            @topic=SignUpTopic.find(params[:topic_id])
            @topic.no_of_reviews += 1
            @topic.save
          end
          @participant_review_count = Participant.find(params[:contributor_id])
          @participant_review_count.no_of_reviews +=1
          @participant_review_count.save
          
          
        else
          flash[:error] = "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      end
    rescue
       msg = $!
    end    
    redirect_to :controller => 'student_review',:action => 'list', :id => params[:participant_id]  
  end
  
  
  
  def add_metareviewer    
    mapping = ResponseMap.find(params[:id])  
    msg = String.new
    begin
      user = get_user(params)   
      regurl = url_for :action => 'add_user_to_assignment', :id => mapping.id, :user_id => user.id               
      reviewer = get_reviewer(user,mapping.assignment,regurl)
      
      if MetareviewResponseMap.find(:first, :conditions => ['reviewed_object_id = ? and reviewer_id = ?',mapping.id,reviewer.id]) != nil
         raise "The metareviewer \""+reviewer.user.name+"\" is already assigned to this reviewer."
      end
      MetareviewResponseMap.create(:reviewed_object_id => mapping.id,                        
                                   :reviewer_id => reviewer.id,
                                   :reviewee_id => mapping.reviewer.id)                         
    rescue  
      msg = $!
    end
    redirect_to :action => 'list_mappings', :id => mapping.assignment.id, :msg => msg                                  
  end 
  
  def get_user(params)      
      if params[:user_id]
        user = User.find(params[:user_id])
      else
        user = User.find_by_name(params[:user][:name])
      end    
      if user.nil?
         newuser = url_for :controller => 'users', :action => 'new' 
         raise "Please <a href='#{newuser}'>create an account</a> for this user to continue."
      end 
      return user
  end
  
  def get_reviewer(user,assignment,regurl)      
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(user.id,assignment.id)
      if reviewer.nil?
         raise "\"#{user.name}\" is not a participant in the assignment. Please <a href='#{regurl}'>register</a> this user to continue."
     end
     return reviewer
  end  
  
  
  def add_user_to_assignment
    if params[:contributor_id]
      assignment = Assignment.find(params[:id]) 
    else
      mapping = ResponseMap.find(params[:id])
      assignment = mapping.assignment
    end
         
    user = User.find(params[:user_id])
    begin
      assignment.add_participant(user.name)
    rescue
      flash[:error] = $!
    end    
    if params[:contributor_id]
      redirect_to :action => 'add_reviewer',     :id => params[:id], :user_id => user.id, :contributor_id => params[:contributor_id]
    else
      redirect_to :action => 'add_metareviewer', :id => params[:id], :user_id => user.id
    end
  end
  
 
  def delete_all_reviewers_and_metareviewers
    assignment = Assignment.find(params[:id])
    failedCount = delete_mappings(assignment.review_mappings,params[:force])   
    if failedCount > 0
      url_yes = url_for :action => 'delete_all_reviewers_and_metareviewers', :id => params[:id], :force => 1
      url_no  = url_for :action => 'delete_all_reviewers_and_metareviewers', :id => params[:id]
      flash[:error] = "A delete action failed:<br/>#{failedCount} reviews exist for these mappings. Delete these mappings anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"            
    else
      flash[:note] = "All review mappings for this assignment have been deleted."             
    end     
    redirect_to :action => 'list_mappings', :id => params[:id]   
  end  
  
  def delete_all_reviewers      
    assignment = Assignment.find(params[:id])
    contributor = assignment.get_contributor(params[:contributor_id])
    mappings = contributor.review_mappings
    assignment.questionnaires.each do |a|
       if a.display_type == "Review"
      @questionnaire = a
        end
  end
  @is_static = Questionnaire.find(@questionnaire.id)
  
    if(@is_static.is_static == 0)
    flash[:error] = "This assignment has a dynamic review. Cannot delete all the reviewers... "
    redirect_to :action => 'list_mappings', :id => params[:id]
    return
    end
    
    failedCount = delete_mappings(mappings, params[:force])
    if failedCount > 0
      url_yes = url_for :action => 'delete_all_reviewers', :id => assignment.id, :contributor_id => contributor.id, :force => 1
      url_no  = url_for :action => 'delete_all_reviewers', :id => assignment.id, :contributor_id => contributor.id
      flash[:error] = "A delete action failed:<br/>#{failedCount} reviews and/or metareviews exist for these mappings. Delete these mappings anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"            
    else
      flash[:note] = "All review mappings for \""+contributor.name+"\" have been deleted."             
    end      
    redirect_to :action => 'list_mappings', :id => assignment.id
  end
  
  def delete_all_metareviewers    
    mapping = ResponseMap.find(params[:id])    
    
    mmappings = MetareviewResponseMap.find_all_by_reviewed_object_id(mapping.id)
    failedCount = delete_mappings(mmappings, params[:force])
    if failedCount > 0
      url_yes = url_for :action => 'delete_all_metareviewers', :id => mapping.id, :force => 1
      url_no  = url_for :action => 'delete_all_metareviewers', :id => mapping.id
      flash[:error] = "A delete action failed:<br/>#{failedCount} metareviews exist for these mappings. Delete these mappings anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"                  
    else
      flash[:note] = "All metareview mappings for contributor \""+mapping.reviewee.name+"\" and reviewer \""+mapping.reviewer.name+"\" have been deleted."      
    end
    redirect_to :action => 'list_mappings', :id => mapping.assignment.id
  end   
  
  def delete_mappings(mappings, force=nil)
    failedCount = 0
    mappings.each{ 
       |mapping|
       assignment_id = mapping.assignment.id
       begin         
         mapping.delete(force)
       rescue
         failedCount += 1
       end
    } 
    return failedCount
  end
        
  def delete_participant
    
    
    contributor = AssignmentParticipant.find(params[:id])
    name = contributor.name
    assignment_id = contributor.assignment
    @assign = Assignment.find(assignment_id)
   @assign.questionnaires.each do |a|
       if a.display_type == "Review"
      @questionnaire = a
        end
  end
  @is_static = Questionnaire.find(@questionnaire.id)
  
    if(@is_static.is_static == 0)
    flash[:error] = "This assignment has a dynamic review. Cannot delete the reviewer... "
    redirect_to :action => 'list_mappings', :id => assignment_id
    return
    end
    begin
      contributor.destroy
      flash[:note] = "\"#{name}\" is no longer a participant in this assignment."      
    rescue
      flash[:error] = "\"#{name}\" was not removed. Please ensure that \"#{name}\" is not a reviewer or metareviewer and try again."
    end     
    redirect_to :action => 'list_mappings', :id => assignment_id
  end
  
  def delete_reviewer
    mapping = ResponseMap.find(params[:id]) 
    assignment_id = mapping.assignment.id
    begin
      mapping.delete
      flash[:note] = "The review mapping for \""+mapping.reviewee.name+"\" and \""+mapping.reviewer.name+"\" have been deleted."        
    rescue      
      flash[:error] = "A delete action failed:<br/>" + $! + "Delete this mapping anyway?&nbsp;<a href='/review_mapping/delete_review/"+mapping.id.to_s+"'>Yes</a>&nbsp;|&nbsp;<a href='/review_mapping/list_mappings/#{assignment_id}'>No</a>"     
    end
    redirect_to :action => 'list_mappings', :id => assignment_id
  end
  
  def delete_metareviewer
    mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    flash[:note] = "The metareview mapping for "+mapping.reviewee.name+" and "+mapping.reviewer.name+" have been deleted."
    
    begin 
      mapping.delete
    rescue
      flash[:error] = "A delete action failed:<br/>" + $! + "<a href='/review_mapping/delete_metareview/"+mapping.id.to_s+"'>Delete this mapping anyway>?"     
    end
    
    redirect_to :action => 'list_mappings', :id => assignment_id
  end

  
  def delete_review
    mapping = ResponseMap.find(params[:id])
    mapping.response.delete          
    redirect_to :action => 'delete_reviewer', :id => mapping.id
  end
  
  def delete_metareview
    mapping = MetareviewResponseMap.find(params[:id])
    metareview = mapping.response
    metareview.delete
    mapping.delete
    redirect_to :action => 'list_mappings', :id => mapping.review_mapping.assignment_id
  end
  
  def delete_rofreviewer
    mapping = ResponseMapping.find(params[:id])
    revmapid = mapping.review_mapping.id
    mapping.delete
    
    flash[:note] = "The review of reviewer has been deleted."
    redirect_to :action => 'list_rofreviewers', :id => revmapid  
  end     
    
  def list       
    all_assignments = Assignment.find(:all, :order => 'name', :conditions => ["instructor_id = ?",session[:user].id])
    
    letter = params[:letter]
    if letter == nil
      letter = all_assignments.first.name[0,1].downcase
    end 
    
    @letters = Array.new
    @assignments = Assignment.paginate(:page => params[:page], :order => 'name',:per_page => 10, :conditions => ["instructor_id = ? and substring(name,1,1) = ?",session[:user].id, letter])    
  
    all_assignments.each {
       | assignObj |
       first = assignObj.name[0,1].downcase
       if not @letters.include?(first)
          @letters << first  
       end
    }       
  end    
  
  def list_mappings
    if params[:msg]
      flash[:error] = params[:msg]
    end
    @assignment = Assignment.find(params[:id])       
    if @assignment.team_assignment
      @items = AssignmentTeam.find_all_by_parent_id(@assignment.id) 
      @items.sort!{|a,b| a.name <=> b.name}
    else
      @items = AssignmentParticipant.find_all_by_parent_id(@assignment.id) 
      @items.sort!{|a,b| a.fullname <=> b.fullname}
    end
  end
  
  def list_sortable
    @assignment = Assignment.find(params[:id])
    @entries = Array.new 
    index = 0
    if @assignment.team_assignment
      contributors = AssignmentTeam.find_all_by_parent_id(@assignment.id)       
    else
      contributors = AssignmentParticipant.find_all_by_parent_id(@assignment.id)
    end
    contributors.sort!{|a,b| a.name <=> b.name}    
    contributors.each{
      |contrib|
      review_mappings = ResponseMap.find_all_by_reviewed_object_id_and_reviewee_id(@assignment.id,contrib.id)
      
      if review_mappings.length == 0
        single = Array.new
        single[0] = contrib.name
        single[1] = "&nbsp;"
        single[2] = "&nbsp;"
        @entries[index] = single
        index += 1
      else
      review_mappings.sort!{|a,b| a.reviewer.name <=> b.reviewer.name}
      review_mappings.each{
        |review_map|
        metareview_mappings = MetareviewResponseMap.find_all_by_reviewed_object_id(review_map.id)
        if metareview_mappings.length == 0
          single = Array.new
          single[0] = contrib.name
          single[1] = review_map.reviewer.name
          single[2] = "&nbsp;"
          @entries[index] = single
          index += 1
        else
          metareview_mappings.sort!{|a,b| a.reviewer.name <=> b.reviewer.name}
          metareview_mappings.each{
            |metareview_map|
              single = Array.new
              single[0] = contrib.name
              single[1] = review_map.reviewer.name
              if metareview_map.review_reviewer == nil
                single[2] = metareview_map.reviewer.name
              else
                single[2] = metareview_map.review_reviewer.name
              end
              @entries[index] = single
              index += 1
          }
        end
      }
      end
    }
  end  
  
  def generate_reviewer_mappings
    assignment = Assignment.find(params[:id])
    assignment.update_attribute('review_strategy_id',1)
    assignment.update_attribute('mapping_strategy_id',1)    
       
    if params[:selection]
      
      mapping_strategy = {}
      params[:selection].each{|a|
      if a[0] =~ /^m_/
        mapping_strategy[a[0]] = a[1]
      end
    }
    else
      mapping_strategy = 1
    end      
      
    if assignment.update_attributes(params[:assignment])
      begin
        assignment.assign_reviewers(mapping_strategy)        
      rescue
        flash[:error] = "Reviewer assignment failed. Cause: " + $!
      ensure
        redirect_to :action => 'list_mappings', :id => assignment.id
      end
    else
      @wiki_types = WikiType.find(:all)
      redirect_to :action => 'list_mappings', :id => assignment.id
    end    
  end  

  #this is for staggered deadline assignment. Can be merged later
  def automatic_reviewer_mapping
    assignment = Assignment.find(params[:id])
    assignment.update_attribute('review_strategy_id',1)
    assignment.update_attribute('mapping_strategy_id',1)

    message = assignment.assign_reviewers_staggered(params[:assignment][:num_reviews], params[:assignment][:num_review_of_reviews])
    flash[:note] = message
    redirect_to :action => 'list_mappings', :id => assignment.id
  end
  
  
  def select_mapping
    @assignment = Assignment.find(params[:id])
    @review_strategies = ReviewStrategy.find(:all, :order => 'name')
    @mapping_strategies = MappingStrategy.find(:all, :order => 'name')    
  end

  #Start of Review report code
  #Author Uma Mahesh Katakam
  def review_report
    @id = params[:id]  #contains the assignment id
    @assignment = Assignment.find(params[:id])
    if @assignment.team_assignment
      @type = "TeamReviewResponseMap"
    else
      @type = "ParticipantReviewResponseMap"
    end
    
    
    #find all reviewers for this assignment
    @reviewers = ResponseMap.find(:all,:select => "DISTINCT reviewer_id", :conditions => ["reviewed_object_id = ? and type = ? ", @id, @type] )
    @review_questionnaire_id = get_review_questionnaire_id_for_assignment(@assignment) 
    # by Abhishek, to get the scores given by each reviewer
    #arranged as the hash @review_scores[reveiwer_id][reviewee_id] = score for this particular assignment
    @review_scores = compute_reviews_hash( @assignment.id)    
    if(@review_questionnaire_id)
      @review_questionnaire = Questionnaire.find(@review_questionnaire_id)
      @maxscore = @review_questionnaire.max_question_score
      @review_questions = @review_questionnaire.questions
    end
    @userid = session[:user].id
  end
  
  def search
    @assignment = Assignment.find(params[:id])
    @id = params[:id]
    
    if @assignment.team_assignment
      @type = "TeamReviewResponseMap"
    else
      @type = "ParticipantReviewResponseMap"
    end
    
    @us = User.find(:all, :select => "DISTINCT id", :conditions => ["fullname LIKE ?", '%'+params[:user][:fullname]+'%'])
    @participants = Participant.find(:all, :select => "DISTINCT id", :conditions => ["user_id IN (?) and parent_id = ?", @us, @assignment.id] )
    @review_scores = compute_reviews_hash( @assignment.id)
    @reviewers = ResponseMap.find(:all,:select => "DISTINCT reviewer_id", :conditions => ["reviewed_object_id = ? and type = ? and reviewer_id IN (?) ", @id, @type, @participants] )
    @review_questionnaire_id =get_review_questionnaire_id_for_assignment(@assignment) 
    @review_questionnaire = Questionnaire.find(@review_questionnaire_id)
    @review_questions = @review_questionnaire.questions
    render :action => 'review_report'
  end
  
  #end of my code
  
  ##### Abhishek - To get the scores by each reviewer - Populating "scores-awarded" column ####
  ##### returning hash review_scores[reviewer_id][reviewee_id] = score ##############
  def compute_reviews_hash(assignment_id)
    
    @assignment = Assignment.find(assignment_id)
    review_questionnaire_id =get_review_questionnaire_id_for_assignment(@assignment) 
    @questions = Question.find(:all, :conditions =>["questionnaire_id = ?", review_questionnaire_id])
    @review_scores = Hash.new
    if (@assignment.team_assignment)
      @response_type = "TeamReviewResponseMap"
    else
      @response_type = "ParticipantReviewResponseMap"
    end
    
    
    @myreviewers = ResponseMap.find(:all,:select => "DISTINCT reviewer_id", :conditions => ["reviewed_object_id = ? and type = ? ", @assignment.id, @type] )
    
    @response_maps=ResponseMap.find(:all, :conditions =>["reviewed_object_id = ? and type = ?", @assignment.id, @response_type])
    for response_map in @response_maps
      ## checking if response is there
      @corresponding_response = Response.find(:first, :conditions =>["map_id = ?", response_map.id])
      @respective_scores = Hash.new
      if (@review_scores[response_map.reviewer_id] != nil)
        @respective_scores = @review_scores[response_map.reviewer_id]
      end
      if (@corresponding_response != nil)
        @this_review_score_raw = Score.get_total_score(@corresponding_response, @questions)
        @this_review_score = ((@this_review_score_raw*100).round/100.0)
      else
        @this_review_score = 0.0
      end
      @respective_scores[response_map.reviewee_id] = @this_review_score
      @review_scores[response_map.reviewer_id] = @respective_scores
    end
    return @review_scores
  end
  
  def get_review_questionnaire_id_for_assignment(assignment)
    @revqids = []
    
    @revqids = AssignmentQuestionnaires.find(:all, :conditions => ["assignment_id = ?",assignment.id])
    @revqids.each do |rqid|
      rtype = Questionnaire.find(rqid.questionnaire_id).type
      if( rtype == ReviewQuestionnaire)
        @review_questionnaire_id = rqid.questionnaire_id
      end
      
    end
    return @review_questionnaire_id
  end
  
  def distribution
  
    @assignment = Assignment.find(params[:id])
    @review_questionnaire_id =get_review_questionnaire_id_for_assignment(@assignment)   
    @review_questionnaire = Questionnaire.find(@review_questionnaire_id)
    @review_questions = @review_questionnaire.questions
    @scores = [0,0,0,0,0,0,0,0,0,0]
    t_score = 0
    if(@assignment.team_assignment)# IF TEAM aSS
      @teams = Team.find_all_by_parent_id(params[:id])
      @objtype = "TeamReviewResponseMap"
    else
      @teams = Participant.find_all_by_parent_id(params[:id])
      @objtype = "ParticipantReviewResponseMap"
    end
    
    @teams.each do |team|
      #@qid = QuestionnaireType.find_by_name("Review").id
      @sc = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?",team.id,  @objtype])
      @score_distribution = Hash.new
      t_score = 0
      if @sc!= nil
        t_score = @sc.score
      end
      if (t_score != 0)
        
        @scores[(t_score/10).to_i] =  @scores[(t_score/10).to_i] + 1
        if(@score_distribution[(t_score/10).to_i] == nil)
          @score_distribution[(t_score/10).to_i] = 1
        else
          @score_distribution[(t_score/10).to_i] = @score_distribution[(t_score/10).to_i] + 1
        end
      end
    end
    
    
    dataset = GoogleChartDataset.new :data => @scores, :color => '9A0000'
    data = GoogleChartData.new :datasets => [dataset]
    axis = GoogleChartAxis.new :axis  => [GoogleChartAxis::BOTTOM, GoogleChartAxis::LEFT]
    @chart1 = GoogleBarChart.new :width => 500, :height => 200
    @chart1.data = data
    @chart1.axis = axis
    
    
    
    
    ###################### Second Graph ####################
    
    
    
    @max_score = 0
    @review_distribution =[0,0,0,0,0,0,0,0,0,0]
    ### For every responsemapping for this assgt, find the reviewer_id and reviewee_id #####
    @reviews_not_done = 0
    @response_maps =  ResponseMap.find(:all, :conditions =>["reviewed_object_id = ? and type = ?", @assignment.id, @objtype])
    review_report = compute_reviews_hash(@assignment.id)
    for response_map in @response_maps
      @score_for_this_review = review_report[response_map.reviewer_id][response_map.reviewee_id]  
      if(@score_for_this_review != 0)
        @review_distribution[(@score_for_this_review/10).to_i] = @review_distribution[(@score_for_this_review/10).to_i] + 1 
        if (@review_distribution[(@score_for_this_review/10).to_i] > @max_score)
          @max_score = @review_distribution[(@score_for_this_review/10).to_i]
        end
      else
        @reviews_not_done +=1
      end
    end
    
    dataset2 = GoogleChartDataset.new :data => @review_distribution, :color => '9A0000'
    data2 = GoogleChartData.new :datasets => [dataset2]
    axis2 = GoogleChartAxis.new :axis  => [GoogleChartAxis::BOTTOM, GoogleChartAxis::LEFT]
    
    @chart2 = GoogleBarChart.new :width => 500, :height => 200
    @chart2.data = data2
    @chart2.axis = axis2
    
    
    
  end
  
  
end
