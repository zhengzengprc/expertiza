class CreateMicrotasks < ActiveRecord::Migration
  def self.up
    create_table :microtasks do |t|
      t.text :name
      t.string :directory_path
      t.integer :course_id
      t.integer :instructor_id
      t.boolean :require_signup
      t.integer :max_choosers
      t.integer :submitter_count
      t.datetime :submission_deadline
      t.timestamps
      end
  end
  execute "INSERT INTO `menu_items` VALUES (1,NULL,'microtask','Microtask',1,NULL,1);"
  def self.down
    drop_table :microtasks
  end
end
