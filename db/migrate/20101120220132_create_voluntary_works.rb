class CreateVoluntaryWorks < ActiveRecord::Migration
  def self.up
    create_table :voluntary_works do |t|
      t.string :name
      t.float :weight
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :voluntary_works
  end
end
