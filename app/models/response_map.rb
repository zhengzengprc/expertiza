class ResponseMap < ActiveRecord::Base
  belongs_to :reviewer, :class_name => 'Participant', :foreign_key => 'reviewer_id'
  has_one :response, :class_name => 'Response', :foreign_key => 'map_id'
  
  def self.get_assessments_for(participant)
    responses = Array.new   
                                                                             
    if participant
      maps = find(:all, :conditions => ['reviewee_id = ? and type = ?',participant.id,self.to_s])
      maps.each{ |map|
        if map.response
          responses << map.response
        end
      }
      #responses = Response.find(:all, :include => :map, :conditions => ['reviewee_id = ? and type = ?',participant.id, self.to_s])      
      responses.sort! {|a,b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    return responses    
  end 
  
  def delete(force = nil)
    if self.response != nil and !force
      raise "A response exists for this mapping."
    elsif self.response != nil
      self.response.delete
    end    
    self.destroy
  end    
  
  def show_review()
    return nil
  end
  
  def show_feedback()
    return nil
  end
  
  # E3 task list - determine if info has been submitted but not reviewed
  def ready_for_review()
    self.response.nil?   # if no response submitted then ready to review 
  end

  # E3 task list - determine if displayed task name should be overridden for this response_map
  def task_name_override()
    nil  
  end
end
