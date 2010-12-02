class AssignmentJobs < ActiveRecord::Base
  belongs_to :assignments, :class_name => "Assignment", :foreign_key => "assignment_id"
end