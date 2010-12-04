class AddColumnToTeam < ActiveRecord::Migration
  def self.up
    add_column :teams, :number_of_assigned_reviews, :integer, :default =>0
  end

  def self.down
    remove_column :teams, :number_of_assigned_reviews
  end
end
