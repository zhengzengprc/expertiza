class AddInTasklistToDeadlineTypes < ActiveRecord::Migration
  def self.up
    add_column :deadline_types, :in_submitter_tasklist, :boolean
    add_column :deadline_types, :in_reviewer_tasklist, :boolean
    
    # set defaults for task list inclusion
    deadlines = DeadlineType.find(:all)
    deadlines.each{ 
      | deadline | 
      deadline.in_submitter_tasklist = ["submission", "resubmission", "metareview"].include?(deadline.name)
      deadline.in_reviewer_tasklist = ["review", "rereview"].include?(deadline.name)
      deadline.save  
    }

  end

  def self.down
    remove_column :deadline_types, :in_reviewer_tasklist
    remove_column :deadline_types, :in_submitter_tasklist
  end
end
