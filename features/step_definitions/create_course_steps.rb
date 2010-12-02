require 'firewatir'

When /"([\w[\d\w]+)" logs on through the logon page/ do |user_name|
  ff=FireWatir::Firefox.new
  #logon 
  visit(logon_path)
  fill_in( "User Name", :with => user_name )
  fill_in( "Password", :with => user_name )
  click_button( "Login" )
    
  #now we should be on the homepage
  #since there is no id associated with the create course button, we can't
  #do a javascript onmouseover event
  ff.link("/course/new?private=0").click #public course
  ff.text_field(:name,"course[name]").set("CSC517-test")
  ff.text_field(:name,"course[directory_path]").set("/test/directory")
  ff.text_field(:name,"course[info]").set("Object Oriented Language System")  
  ff.button(:name, "commit").click #hit create
  
  @new_course = Course.find_by_name!("CSC517-test")  # should be created
  
end #this test should initially fail

