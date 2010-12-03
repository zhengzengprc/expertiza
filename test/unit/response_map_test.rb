require File.dirname(__FILE__) + '/../test_helper'

class ResponseMapTest < Test::Unit::TestCase
  fixtures :response_maps, :participants

  # Replace this with your real tests.
    
  def test_get_assessments_for
    @participant = participants(:par14)
    #debugger
    responses = FeedbackResponseMap.get_assessments_for(@participant)
    #print responses
    #assert responses == response_maps(:response_map7)                        
    assert responses,@participant.get_feedback
    
  end
end
