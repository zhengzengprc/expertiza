class AddColumnToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :is_static, :integer, :default => 1
    add_column :questionnaires, :review_granularity, :text, :null => true
    add_column :questionnaires, :review_selection_type, :text, :null => true
  end

  def self.down
    remove_column :questionnaires, :is_static
    remove_column :questionnaires, :review_granularity
    remove_column :questionnaires, :review_selection_type
  end
end
