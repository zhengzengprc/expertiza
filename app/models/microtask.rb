class Microtask < ActiveRecord::Base
  belongs_to :course, :class_name => 'Course', :foreign_key => 'course_id'
  def self.get_microtask_deadline(microtaskid)
        
    microtaskinst =Microtask.find_by_id(microtaskid)
    due_date=microtaskinst.submission_deadline
    if due_date != nil 
      if Time.now.utc > Time.parse(due_date.to_s).utc
        return "COMPLETE"
      else
        return due_date
      end
      return
    end
  end
  
  def self.get_slot(microtaskid)
    puts microtaskid
    numofrows=MicrotaskParticipant.count(:conditions => ["microtaskid = ?",microtaskid])
    puts numofrows
    microtaskinst=Microtask.find_by_id(microtaskid)
    puts microtaskinst.max_choosers
    available_slots=microtaskinst.max_choosers - numofrows
  
    return available_slots
   end
  def get_path
    if self.course_id == nil and self.instructor_id == nil
      raise "Path can not be created. Course id must be associated with either a course or an instructor."
    end
  end
end
