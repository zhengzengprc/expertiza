class AddTablesForMessageBoard < ActiveRecord::Migration
  def self.up
  create_table :cheers, :force => true do |t|
    t.integer :post_id 
    t.integer :cheercount
    t.integer :uncheercount
    t.string  :name
    # adds 'created_at' and 'updated_at' fields
      t.timestamps
  end

  create_table :followers, :force => true do |t|
    t.string  :name
    t.integer :followeruserid
 # adds 'created_at' and 'updated_at' fields
      t.timestamps
  end

  create_table :posts, :force => true do |t|
    t.string  :name
    t.text    :posttext
    t.integer :parentpost
    # adds 'created_at' and 'updated_at' fields
      t.timestamps
  end
  end

  def self.down
  drop_table :cheers
  drop_table :followers
  drop_table :posts
  end
end
