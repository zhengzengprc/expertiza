class AddNewQuestionTypes < ActiveRecord::Migration
  def self.up
    # add a new column "type" that tracks the type of a question. valid types are documented in the "GRADING_TYPES" 
    # variable in question.rb.
    add_column :questions, :type, :integer, :null => true   
    # add a new column that stores the names associated with checkbox, radio button, and heterogenous questions. 
    # e.g. save the names of the options a question has.
    add_column :questions, :label, :string, :null => true
  end
  
  def self.down
    remove_column :questions, :type
    remove_column :questions, :label
  end
end
