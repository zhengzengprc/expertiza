class TeamsUser < ActiveRecord::Base  
  belongs_to :user
  belongs_to :team
  
  def name
    self.user.name
  end
  
  def delete
    TeamUserNode.find_by_node_object_id(self.id)
    team = self.team
    self.destroy
    if team.teams_users.length == 0
      team.delete    
    end
  end
  
  # Following method seems WRONG, because it does not take into acct. assignment_id.
  def self.find_teamid_for_userid(user_id)
    TeamsUser.find_by_sql("SELECT tu.team_id FROM teams_users tu WHERE tu.user_id ="+ user_id);   
  end
end