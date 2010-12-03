class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table "courses", :force => true do |t|
      #t.column "title", :string
      t.column "name", :string
      t.column "instructor_id", :integer
      t.column "directory_path", :string
      t.column "info", :text

      t.timestamps
      
    end

    add_index "courses", ["instructor_id"], :name => "fk_course_users"

     add_column "courses", :cdate, :integer, :default => 14
     add_column "courses", :private, :integer
    
    execute "alter table courses
             add constraint fk_course_users
             foreign key (instructor_id) references users(id)"    
  end

  def self.down
    drop_table "courses"    
  end
end
