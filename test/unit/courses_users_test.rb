require File.dirname(__FILE__) + '/../test_helper'

class CoursesUsersTest < ActiveSupport::TestCase
 fixtures :courses, :users
  #TODO verify if fixture is correct
  # Replace this with your real tests.
# Need to add more tests
  def test_truth
    assert true
  end

  def test_import
    row = Array.new
    row[0] = "s1"
    row[1] = "Student, One"
    row[2] = "one.student@blah.foo"
    row[3] = "s1"

    session = Hash.new
    session[:user] = users(:superadmin)


    #course_user = CoursesUsers.new
    course = Course.new
    course= courses(:course_nil)
    id = course.id
     #TODO after getting courses_users table
    #cu = CoursesUsers.count
    #CoursesUsers.import(row, session,id)
    #assert_equal cu+1,CoursesUsers.count

    id1 = nil
    assert_raise(MissingObjectIDError){CoursesUsers.import(row, session,id1)}
    #TODO after getting courses_users table
    #assert_raise(ImportError){CoursesUsers.import(row,session,id)}
    

   end
end

