require File.dirname(__FILE__) + '/../test_helper'

class DeadlineTypeTest < Test::Unit::TestCase
  fixtures :deadline_types

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_create_new_deadline_type
    #check if a new deadline can be created. No validations present in the model
    d = DeadlineType.new
    d.name = "New Deadline"
    d.in_submitter_tasklist = true
    assert d.save
  end

  def test_get_submitter_list_types

    assert DeadlineType.get_submitter_list_types.include?(deadline_types(:deadline_type_review).id)
    assert !DeadlineType.get_submitter_list_types.include?(deadline_types(:deadline_type_rereview).id)
  end

  def test_get_reviewer_list_types
    #in_reviewer_tasklist is true for this record.
    assert DeadlineType.get_reviewer_list_types.include?(deadline_types(:deadline_type_metareview).id)

    #in_reviewer_tasklist is false for this record. Hence this method does not return that id
    assert !DeadlineType.get_reviewer_list_types.include?(deadline_types(:deadline_type_rereview).id)
  end

end
