require File.dirname(__FILE__) + '/../test_helper'

class DueDateTest < Test::Unit::TestCase
  fixtures :due_dates

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_set_duedate
    d = due_dates(:due_date0)
    duedate = DueDate.new
    duedate.deadline_type_id = d.deadline_type_id
    duedate.assignment_id = d.assignment_id
    duedate.round = d.round
    assert duedate.save
  end

  
end
