class AddLastPosterNameToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :last_poster_name, :string
  end

  def self.down
    remove_column :topics, :last_poster_name
  end
end
