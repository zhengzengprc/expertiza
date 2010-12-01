class AddColumnToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :no_of_reviews, :integer, :default =>0
  end

  def self.down
    remove_column :participants, :no_of_reviews
  end
end
