class AddTablesForMessageBoard < ActiveRecord::Migration
  def self.up
  create_table :cheers, :force => true do |t|
    t.integer :post_id 
    t.integer :cheercount
    t.integer :uncheercount
    t.string  :name
  end

  create_table :followers, :force => true do |t|
    t.string  :name
    t.integer :followeruserid
 
  end

  create_table :posts, :force => true do |t|
    t.string  :name
    t.text    :posttext
    t.integer :parentpost
  end
  end

  def self.down
  drop_table :cheers
  drop_table :followers
  drop_table :posts
  end
end
