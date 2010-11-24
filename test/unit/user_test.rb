require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
	
  fixtures :users
  
  # Test user retrieval by email
  def test_find_by_login_email
    user = User.find_by_login('admin@foo.edu')
    assert_equal 'admin', user.name
  end
  
  # Test user retrieval by name
  def test_get_by_login_name
    user = User.find_by_login('admin@foo.edu')
    assert_equal 'admin', user.name
  end

  # 101 add a new user 
  def test_add_user
    user = User.new
    user.name = "testStudent1"
	user.password = Digest::SHA1.hexdigest("test")
	user.fullname = "test Student 1"
	user.role_id = "1"
    assert user.save
  end 
  
  # 102 Add a user with existing name 
  def test_add_user_with_exist_name
    user = User.new
	user.name = users(:admin).name
	user.password = Digest::SHA1.hexdigest("test")
	user.fullname = "Duplicated Test Admin"
	user.role_id = "3"
    assert !user.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], user.errors.on(:name)
  end
  
  # 103 Check valid user name and password   
  def test_add_user_with_invalid_name
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?(:name)
    #assert user.errors.invalid?(:password)
  end
  # 202 edit a user name to an invalid name (e.g. blank)
  def test_update_user_with_invalid_name
    user = users(:student1)
    user.name = "";
    assert !user.valid?
  end
  # 203 Change a user name to an existing name.
  def test_update_user_with_existing_name
    user = users(:student1)
    user.name = users(:student2).name;
    assert !user.valid?
  end  
end
