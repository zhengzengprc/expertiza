class AddsubmittedHyperlinktomicrotaskParticipants < ActiveRecord::Migration
  def self.up
    add_column :microtask_participants, :submitted_hyperlink, :text
  end

  def self.down
    remove_column :microtask_participants, :submitted_hyperlink, :text
  end
end
