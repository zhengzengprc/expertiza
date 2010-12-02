When /"([\w[\d\w]+)" logs on through the logon page/ do |user_name|
  visit(logon_path)
  fill_in( "User Name", :with => user_name )
  fill_in( "Password", :with => user_name )
  click_button( "Login" )
end #this test should initially fail

