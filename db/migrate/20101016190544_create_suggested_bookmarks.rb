class CreateSuggestedBookmarks < ActiveRecord::Migration
  def self.up
    create_table :suggested_bookmarks do |t|
      t.integer :sign_up_topic_id
      t.string :bookmark_link
      t.integer :user_id
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :suggested_bookmarks
  end
end
