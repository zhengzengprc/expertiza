#Link to the  "test student signup" project
And /^Given that assignment test student signup is listed$/ do
  #Link to the assignment page
  should have_link 'Assignments'
  click_link 'Assignments'

  #First log in then click the accept the term
  if(!find_link('Accept').nil?)
     click_link 'Accept'
  end

  #Link to the sign up page
  should have_link "test student signup"

end

#Sign up a topic
Then /^I click the test student signup link$/ do
  should have_link "test student signup"
  click_link "test student signup"
end

#Succsseful link to the signup sheet
Then /^I click the Signup sheet link$/ do
  should have_link "Signup sheet"
  click_link "Signup sheet"
end

#Test if the signup action works
And /^I click on signup action$/ do
  find(:xpath, "//img[@title = 'Signup']/parent::a").should_not be_nil
  find(:xpath, "//img[@title = 'Signup']/parent::a").click()
end

#Check the cancel action works
And /^I verify that the page contains cancel action$/ do
  find(:xpath, "//img[@title = 'Leave Topic']/parent::a").should_not be_nil
end