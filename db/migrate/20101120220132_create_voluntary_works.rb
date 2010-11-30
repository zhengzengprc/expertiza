class CreateVoluntaryWorks < ActiveRecord::Migration
  def self.up
    create_table :voluntary_works do |t|
      t.string :name
      t.float :weight
      t.string :task_type
      t.integer :course_id
     
      t.timestamps
    end
    execute "alter table voluntary_works
             add constraint fk_course_voluntary_works
             foreign key (course_id) references courses(id)"    
  end

  def self.down
    drop_table :voluntary_works
  end
end
