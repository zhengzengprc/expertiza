class AddMicrotaskIdToSignUpTopic < ActiveRecord::Migration
  def self.up
    add_column :sign_up_topics, :microtask_id, :int
  end

  def self.down
    remove_column :sign_up_topics, :microtask_id
  end
end
