class CreatePostTopics < ActiveRecord::Migration
  def self.up
    # this table holds the topics for the message board
    create_table :post_topics do |t|
      # adds 'created_at' and 'updated_at' fields
      t.timestamps
      t.column :topicname, :string
    end
  end

  def self.down
    drop_table :post_topics
  end
end
