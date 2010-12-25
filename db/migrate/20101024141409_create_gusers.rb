class CreateGusers < ActiveRecord::Migration
  def self.up
    create_table :gusers do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :gusers
  end
end
