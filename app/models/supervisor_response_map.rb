class SupervisorResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :review_mapping, :class_name => 'ResponseMap', :foreign_key => 'reviewed_object_id'
  
  def show_review()
    if self.review_mapping.response
      return self.review_mapping.response.display_as_html()+"<br/><hr/><br/>"
    else
      return "<I>No review was performed.</I><br/><hr/><br/>"
    end
  end  
  
  def contributor
    self.review_mapping.reviewee
  end
  
  def questionnaire
    self.assignment.questionnaires.find_by_type('SupervisorQuestionnaire')
  end  
  
  def get_title
    return "Supervisor Review"
  end  
  
  def assignment
    self.review_mapping.assignment
  end
  
  def self.export(csv,parent_id)    
 
  end
  
  def self.get_export_fields
            
  end   
  
  def self.import(row,session,id)

  end  
  
 def ready_for_review()

  end

 def task_name_override()
 
  end

end