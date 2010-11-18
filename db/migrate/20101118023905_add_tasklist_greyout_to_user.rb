class AddTasklistGreyoutToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :tasklist_greyout, :boolean
  end

  def self.down
    remove_column :users, :tasklist_greyout
  end
end
