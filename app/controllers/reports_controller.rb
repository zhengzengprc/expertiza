class ReportsController < ApplicationController
  require 'aquarium'
  
  def view
    @assignment_id=14;
    
    @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment_id])
    @late_policy = Assignment.find(@assignment_id).late_policy
    # Find the next due date (after the current date/time), and then find the type of deadline it is.
    @very_last_due_date = DueDate.find(:all,:order => "due_at DESC", :limit =>1)
    @next_due_date = @very_last_due_date[0]
    for due_date in @due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < @next_due_date.due_at
          @next_due_date = due_date
        end
      end
    end
    
    
    @review_phase = @next_due_date.deadline_type_id;
    
    
    
  end
  
include Aquarium::DSL
  around :methods => [:view ] do |join_point, object, *args|
    logger.info "[info] Entering: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result = join_point.proceed
    logger.info "[info] Leaving: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result  # block needs to return the result of the "proceed"!
  end
  
end
