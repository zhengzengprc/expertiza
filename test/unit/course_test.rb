require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :courses

  def setup
    @course = Course.find(courses(:course1).id)
  end
  
  def test_retrieval
    assert_kind_of Course, @course
    assert_equal courses(:course1).name, @course.name
    assert_equal courses(:course1).id, @course.id
    assert_equal courses(:course1).instructor_id, @course.instructor_id
    assert_equal courses(:course1).directory_path, @course.directory_path
    assert_equal courses(:course1).info, @course.info
    assert @course.private
  end
 
  def test_update
    assert_equal courses(:course1).name, @course.name
    @course.name = "Object-Oriented"
    @course.save
    @course.reload
    assert_equal "Object-Oriented", @course.name
  end
  
  def test_destroy
    @course.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Course.find(@course.id) }
  end
  
end
