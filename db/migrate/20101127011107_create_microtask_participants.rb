class CreateMicrotaskParticipants < ActiveRecord::Migration
  def self.up
    create_table :microtask_participants do |t|
      t.integer :userid
      t.integer :microtaskid
      t.integer :grades

      t.timestamps
    end
  end

  def self.down
    drop_table :microtask_participants
  end
end
