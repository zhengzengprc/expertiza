require File.dirname(__FILE__) + '/../test_helper'

class TeamTest < ActiveSupport::TestCase
  fixtures :users
  fixtures :courses
  fixtures :teams
  
  def test_add_team
    team = Team.new
    assert team.save
  end
  
  def test_add_team_member
    #team = teams(:team0)
    currTeam = CourseTeam.new
    course = courses(:course0)
   	currTeam.name = name
   	currTeam.parent_id = course.id
   	
   	assert currTeam.save

   	parent = CourseNode.create(:parent_id => nil, :node_object_id => course.id)
   	TeamNode.create(:parent_id => parent.id, :node_object_id => currTeam.id)

    currTeam.add_member(users(:student1));
    assert currTeam.has_user(users(:student1))
  end
end
