class DeadlineType < ActiveRecord::Base
 
  # returns IDs of all deadline_types with in_submitter_tasklist set
  def self.get_submitter_list_types
    deadlines = DeadlineType.find_all_by_in_submitter_tasklist(true)
    deadlines.collect {|dl| dl.id }
  end
  
  # returns IDs of all deadline_types with in_reviewer_tasklist set
  def self.get_reviewer_list_types
    deadlines = DeadlineType.find_all_by_in_reviewer_tasklist(true)
    deadlines.collect {|dl| dl.id }
  end
end
