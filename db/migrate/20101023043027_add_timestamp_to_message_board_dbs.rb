class AddTimestampToMessageBoardDbs < ActiveRecord::Migration
  def self.up
    # add timestamps to the message board tables
    add_column :posts, :timestamp, :timestamp
    add_column :cheers, :timestamp, :timestamp
    add_column :followers, :timestamp, :timestamp
  end

  def self.down
     # add timestamps to the message board tables
    remove_column :posts, :timestamp
    remove_column :cheers, :timestamp
    remove_column :followers, :timestamp
  end
end
