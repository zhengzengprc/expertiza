class CreateTaskGrays < ActiveRecord::Migration
  def self.up
    create_table :task_grays do |t|

      t.column "userid", :integer, :null=>false
      t.column "grayed", :integer, :default=>0, :null=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :task_grays
  end
end
