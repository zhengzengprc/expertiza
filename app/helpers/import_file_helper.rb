require 'csv'

module ImportFileHelper
 
  def self.define_attributes(row)   
    attributes = {}
    attributes["role_id"] = 1#Role.find_by_name "Student"
    attributes["name"] = row[0].strip
    attributes["fullname"] = row[1]
    attributes["email"] = row[2].strip
    attributes["clear_password"] = row[3].strip
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end

  def self.create_new_user(attributes, session)
    #user = User.new(attributes)
    user = User.new
    user.role_id = attributes["role_id"]
    user.name= attributes["name"]
    user.fullname = attributes["email"]
    user.email = attributes["email"]
    user.clear_password = attributes["clear_password"]
    user. email_on_submission = attributes["email_on_submission"]
    user. email_on_review = attributes["email_on_review"]
    user. email_on_review_of_review = attributes["email_on_review_of_review"]

    user.parent_id = (session[:user]).id
    user.save
   
    user 
  end
end


