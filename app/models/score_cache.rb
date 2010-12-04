class ScoreCache < ActiveRecord::Base
  
  ## makes an entry into score_cache table whenever a response is given/edited.
  ## handles team and individual assignments differently - for individual assignments the reviewee_id = participant_id, for team assignments, reviewee_id = team_id
  def self.update_cache(rid)
    
    presenceflag = 0
    @ass_id = 0
    @userset = []
    @team = 0
    @team_number = 0
    @teamass = 0
    @reviewmap = Response.find(rid).map_id
    @rm = ResponseMap.find(@reviewmap)
    @participant1 = AssignmentParticipant.new
    @the_object_id = 0
    @map_type = @rm.type.to_s
    @t_score = 0
    @t_min = 0
    @teammember = TeamsUser.new
    @t_max = 0
    @myfirst = "before"
    
    
    
    #if (@map_type == "ParticipantReviewResponseMap")
    if(@map_type == "TeamReviewResponseMap")
      @ass_id = @rm.reviewed_object_id
      @assignment1 = Assignment.find(@ass_id)
      @teammember =  TeamsUser.find(:first, :conditions => ["team_id = ?",@rm.reviewee_id])
      @participant1 = AssignmentParticipant.find(:first, :conditions =>["user_id = ? and parent_id = ?", @teammember.user_id, @ass_id])
      @the_object_id = @teammember.team_id
      j= review()
      
# ============= isyed,nbshah2,nbarman===============
# In the elsif part we are including the logic for the curving of scores of the teammate reviews    
# In this part we have made a modification to the score_caches table by including the team_id column      
# we are doing this by creating an instance variable @teammember of model TeamsUser and we use the     
# team_id value of this class to map our user's score of the score_caches to a team using the team_id 
# of the score_caches which we have created
# ============= isyed,nbshah2,nbarman================ 
    elsif(@map_type == "TeammateReviewResponseMap")
      @participant1 = AssignmentParticipant.find(@rm.reviewee_id)
      puts "in the else statement after participant statement"
      @the_object_id = @participant1.id
      puts "after the object_id"
      puts @rm.reviewee_id
      @assignment1 = Assignment.find(@participant1.parent_id)
      @ass_id = @assignment1.id
      @participant = Participant.find(:first, :conditions => ["id = ?", @rm.reviewee_id])
      puts "printing the participant value here"
      puts @participant.user_id
      #team_all= TeamsUser.find_by_sql "select t.team_id from teams_users t, participants p where t.user_id= p.user_id "
      @team_all = TeamsUser.find(:all, :conditions => ["user_id= ?",@participant.user_id])
      for i in @team_all do
        puts i.team_id
      end
      @teammember =  TeamsUser.find(:first, :conditions => ["user_id= ?",@participant.user_id])
       
     @questions = Hash.new    
    questionnaires = @assignment1.questionnaires
    questionnaires.each{
      |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    } 
    @allscores = @participant1.get_scores( @questions)
    
    @scorehash = get_my_scores(@allscores, @map_type) 
    
    
    @p_score = @scorehash[:avg]               
    @p_min = @scorehash[:min]
    @p_max = @scorehash[:max]
     for i in @team_all do
       if i.user_id=@participant.user_id && i.team_id != @teammember.team_id
         @teammember.team_id = i.team_id
       end
     end
     puts i.team_id
      puts "the team memmber "
      puts @teammember.team_id
    @tu = TeamsUser.find(:first,:conditions => ["user_id = ? and team_id = ?", @participant.user_id, @teammember.team_id])
    puts "##############"
    puts @tu.team_id
    puts @tu.user_id
    #puts @teammember.team_id
    sc = ScoreCache.find(:first,:conditions =>["reviewee_id = ? and object_type = ?",  @the_object_id, @map_type ])
    #added
    
    if ( sc == nil)
      puts " in second if"
      presenceflag = 1
      
      @msgs = "first entry"
      sc = ScoreCache.new
      sc.reviewee_id = @the_object_id
      puts @tu
      sc.team_id = @teammember.team_id
     
      range_string = ((@p_min*100).round/100.0).to_s + "-" + ((@p_max*100).round/100.0).to_s
     
      sc.range =    range_string
      sc.score = (@p_score*100).round/100.0
      
      sc.object_type = @map_type                        
      sc.save

      puts @teammember.team_id
      @tu.save
      #=========isyed,nbshah2,nbarman==========
      # included the logic to calculate the curved score here 
       sc1 = ScoreCache.find(:all, :conditions => ["team_id = ?", sc.team_id])
       sc2 = ScoreCache.count(:all, :conditions => ["team_id = ?", sc.team_id])
       puts "sucess"
       puts sc.score
       a = (sc.score)-12.to_f #limits the maximum variation to 12% above or below the indvidual score avg
       puts a
       b = (sc.score)+12.to_f
       puts b
       total = 0
       for id in sc1 do
         total+=id.score
       end
       teamavg=total/sc2
       puts teamavg
       sc3 = sc.score/teamavg
       puts sc3
       curvedscore= sc3*sc.score
       if(curvedscore < a)
          puts "where am i?"
          sc.score = a
          sc.save
          puts sc.score
       elsif(curvedscore > b)
            if(curvedscore > 110)
              puts "i should be here"
              sc.score = 110
              sc.save
              puts sc.score
            else
              puts "am i here?"
              sc.score = b
              sc.save
              puts sc.score
            end
       else
          if(curvedscore >110)
          puts "in the curving else?"
          sc.score = 110
          sc.save
          else
          sc.score = curvedscore
          sc.save
          puts sc.score
          end
       end
    
     
      # make another new tuple for new score
    else
      
      range_string = ((@p_min*100).round/100.0).to_s + "-" + ((@p_max*100).round/100.0).to_s
      puts "second else"
      sc.team_id = @teammember.team_id

      sc.range =    range_string
      sc.score = (@p_score*100).round/100.0
      presenceflag = 2
      sc.save
      
      @tu.save
       sc1 = ScoreCache.find(:all, :conditions => ["team_id = ?", sc.team_id])
       sc2 = ScoreCache.count(:all, :conditions => ["team_id = ?", sc.team_id])
       puts "sucess"
       puts sc.score
       a = (sc.score)-12.to_f
       puts a
       b = (sc.score)+12.to_f
       puts b
       total = 0
       for id in sc1 do
         total+=id.score
       end
       teamavg=total/sc2
       puts teamavg
       sc3 = sc.score/teamavg
       puts sc3
       curvedscore= sc3*sc.score
       if(curvedscore < a)
          sc.score = a
          sc.save
          puts sc.score
       elsif(curvedscore > b)
            if(curvedscore > 110)
              puts "i should be here"
              sc.score = 110
              sc.save
              puts sc.score
            else
              puts "am i here?"
              sc.score = b
              sc.save
              puts sc.score
            end
       else
          if(curvedscore >110)
          puts "in the curving else?"
          sc.score = 110
          sc.save
          else
          sc.score = curvedscore
          sc.save
          puts sc.score
          end
       end
     
      
      
      #look for a consolidated score and change
    #end               
    #added
    end
   

      
      
    else
      @participant1 = AssignmentParticipant.find(@rm.reviewee_id)
      @the_object_id = @participant1.id
      @assignment1 = Assignment.find(@participant1.parent_id)
      @ass_id = @assignment1.id
      j=review() # this is the original code 
    end 
end

#======================isyed, nbshah2, nbarman ===============
# the following function is the original code which we have now put in the function so that
#the original functionality is not affected
def self.review()
  
  @questions = Hash.new    
    questionnaires = @assignment1.questionnaires
    questionnaires.each{
      |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    } 
    @allscores = @participant1.get_scores( @questions)
    
    @scorehash = get_my_scores(@allscores, @map_type) 
    
    
    @p_score = @scorehash[:avg]               
    @p_min = @scorehash[:min]
    @p_max = @scorehash[:max]
    
    sc = ScoreCache.find(:first,:conditions =>["reviewee_id = ? and object_type = ?",  @the_object_id, @map_type ])
    if ( sc == nil)
      presenceflag = 1
      @msgs = "first entry"
      sc = ScoreCache.new
      sc.reviewee_id = @the_object_id
      # sc.assignment_id = @ass_id
      
      range_string = ((@p_min*100).round/100.0).to_s + "-" + ((@p_max*100).round/100.0).to_s
      
      
      
      sc.range =    range_string
      sc.score = (@p_score*100).round/100.0
      
      sc.object_type = @map_type                        
      
      sc.save
      # make another new tuple for new score
    else
      
      range_string = ((@p_min*100).round/100.0).to_s + "-" + ((@p_max*100).round/100.0).to_s
      
      sc.range =    range_string
      sc.score = (@p_score*100).round/100.0
      presenceflag = 2
      sc.save
      #look for a consolidated score and change
    end               
    
end

  def self.get_my_scores( scorehash, map_type)
    ##isolates the scores for the particular item needed
    @p_score = 0
    @p_min = 0  
    @p_max = 0
    
    #  ParticipantReviewResponseMap - Review mappings for single user assignments
    #  TeamReviewResponseMap - Review mappings for team based assignments
    #  MetareviewResponseMap - Metareview mappings
    #  TeammateReviewResponseMap - Review mapping between teammates
    #  FeedbackResponseMap - Feedback from author to reviewer
    
    
    if(map_type == "ParticipantReviewResponseMap")
      
      if (scorehash[:review])
        @p_score = scorehash[:review][:scores][:avg]               
        @p_min = scorehash[:review][:scores][:min]
        @p_max = scorehash[:review][:scores][:max]
      end
    elsif (map_type == "TeamReviewResponseMap")
      if (scorehash[:review])
        @p_score = scorehash[:review][:scores][:avg]               
        @p_min = scorehash[:review][:scores][:min]
        @p_max = scorehash[:review][:scores][:max]
      end
      
    elsif (map_type == "TeammateReviewResponseMap")
      if (scorehash[:review])
        @p_score = scorehash[:teammate][:scores][:avg]               
        @p_min = scorehash[:teammate][:scores][:min]
        @p_max = scorehash[:teammate][:scores][:max]
      end
      
    elsif (map_type == "MetareviewResponseMap")
      if (scorehash[:metareview])
        @p_score = scorehash[:metareview][:scores][:avg]               
        @p_min = scorehash[:metareview][:scores][:min]
        @p_max = scorehash[:metareview][:scores][:max]
      end
    elsif (map_type == "FeedbackResponseMap")
      if (scorehash[:feedback])
        @p_score = scorehash[:feedback][:scores][:avg]               
        @p_min = scorehash[:feedback][:scores][:min]
        @p_max = scorehash[:feedback][:scores][:max]
      end
    end 
    @scoreset = Hash.new
    @scoreset[:avg] = @p_score
    @scoreset[:min] = @p_min
    @scoreset[:max] = @p_max
    return @scoreset
  end
 
end
