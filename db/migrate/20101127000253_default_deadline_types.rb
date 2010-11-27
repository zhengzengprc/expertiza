class DefaultDeadlineTypes < ActiveRecord::Migration
  def self.up
    # set defaults for task list inclusion
    deadlines = DeadlineType.find(:all)
    deadlines.each{ 
      | deadline | 
      deadline.in_submitter_tasklist = ["submission", "resubmission", "switch_topics"].include?(deadline.name)
      deadline.in_reviewer_tasklist = ["review", "rereview", "metareview"].include?(deadline.name)
      deadline.save  
    }
  end

  def self.down
  end
end
