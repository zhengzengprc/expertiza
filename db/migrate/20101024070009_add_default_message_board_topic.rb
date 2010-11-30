class AddDefaultMessageBoardTopic < ActiveRecord::Migration
  def self.up
    t = PostTopic.new
    t.id = 1;
    t.topicname = "General"
    t.save
  end

  def self.down
    
  end
end
