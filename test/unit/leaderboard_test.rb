require 'test_helper'
require "leaderboard"
class LeaderboardTest < ActiveSupport::TestCase
  fixtures :users, :assignments
  
  def test_truth
    assert true
  end
  #FIXME Naming convention not followed in method names in the model
  def test_getIndependentAssignments
#   assert Leaderboard.getIndependentAssignments(users(:student1).id)
#  assert false   
  end
end
