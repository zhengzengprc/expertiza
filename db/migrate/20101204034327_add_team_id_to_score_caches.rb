class AddTeamIdToScoreCaches < ActiveRecord::Migration
  def self.up
    add_column :score_caches, :team_id, :integer
  end

  def self.down
    remove_column :score_caches, :team_id
  end
end
