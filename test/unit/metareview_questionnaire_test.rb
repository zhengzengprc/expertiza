require File.dirname(__FILE__) + '/../test_helper'

class MetareviewQuestionnaireTest < ActiveSupport::TestCase
 fixtures :metareview_questionnaires, :participants, :assignments, :questionnaires
  #TODO verify if correct fixture included
  #fixtures :questionnaires
  # Replace this with your real tests.
  def test_truth
    assert true
  end

 #TODO after getting meta_review_questionnaires table

  def test_get_assessment_for
     participant = Participant.new
     participant = participants(:participant1)
     mrq = MetaReviewQuestionnaire.new
     mrq.get_assessments_for(participant)
   end
  end                                              
