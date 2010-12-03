require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :scores,:questions, :responses, :response_maps, :assignments,:teams, :participants, :questionnaires, :assignment_questionnaires


  def test_compute_scores

      questionnaire1 = Array.new
      questionnaire1<<questionnaires(:questionnaire0)
      questionnaire1<<questionnaires(:questionnaire1)

      question = Array.new
      question<<questions(:question1)
      question<<questions(:question2)
      puts questionnaire1.size
      
      scores = Hash.new
      scores[:participant] = AssignmentParticipant.find_by_parent_id(assignments(:assignment0))
      questionnaire1.each{
        | questionnaire |
        scores[questionnaire.symbol] = Hash.new
        scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(AssignmentParticipant.find_by_parent_id(assignments(:assignment0)))

        scores[questionnaire.symbol][:scores] = Score.compute_scores(scores[questionnaire.symbol][:assessments], question)
          
        assert_not_equal(scores[questionnaire.symbol][:scores],0)
      }

  end

end
