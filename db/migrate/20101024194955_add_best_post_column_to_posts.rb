class AddBestPostColumnToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :best_post, :integer, :default => 0
  end

  def self.down
    remove_column :posts, :best_post
  end
end
 