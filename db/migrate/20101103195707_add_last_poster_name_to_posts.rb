class AddLastPosterNameToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :last_poster_name, :string
  end

  def self.down
    remove_column :posts, :last_poster_name
  end
end
