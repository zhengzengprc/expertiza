class CreateBookmarkRatings < ActiveRecord::Migration
  def self.up
    create_table :bookmark_ratings do |t|
      t.integer :suggested_bookmark_id
      t.integer :rating
      t.integer :team_id

      t.timestamps
    end
  end

  def self.down
    drop_table :bookmark_ratings
  end
end
