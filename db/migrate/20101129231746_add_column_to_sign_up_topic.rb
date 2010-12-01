class AddColumnToSignUpTopic < ActiveRecord::Migration
  def self.up
    add_column :sign_up_topics, :no_of_reviews, :integer, :default =>0
  end

  def self.down
    remove_column :sign_up_topics, :no_of_reviews
  end
end
