class AddCheersToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :cheers, :integer, :default => 0
  end

  def self.down
    remove_column :posts, :cheers
  end
end
