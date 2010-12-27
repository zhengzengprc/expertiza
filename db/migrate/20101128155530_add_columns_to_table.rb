class AddColumnsToTable < ActiveRecord::Migration
  def self.up
    add_column :assignments,:keyword,:string
  end

  def self.down
  end
end
