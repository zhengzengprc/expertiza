require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < ActiveSupport::TestCase
  fixtures :questions

  # Replace this with your real tests.
  def test_truth
    assert true
  end


  def test_txt
    question = Question.new
    question.txt = questions(:question1).txt
    assert !question.valid?
  end

  def test_weight
    question = Question.new
    question.weight = questions(:question1).weight
    assert !question.valid?

    ques = Question.new
    ques.weight = questions(:question3).weight
    assert !question.valid?
  end

  def test_destroy
    qc = Question.count
    q_destroy = questions(:question4)
    q_id = questions(:question4).id
    q_destroy.delete
    assert_equal(QuestionAdvice.find_all_by_question_id(q_id).length,0, "NO ADVICES FOR THIS QUESTION")
    assert_equal qc-1,Question.count
  end


end
