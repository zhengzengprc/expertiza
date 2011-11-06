And /^I open assignment test_submit_assigment$/ do
  #Link to the assignment page
  should have_link 'Assignments'
  click_link 'Assignments'

  #Find the "test_submit_assigment" and click
  should have_link "test_submit_assigment"
  click_link "test_submit_assigment"
end

#Test the your work link if it works
Then /^I click the Your work link$/ do
 should have_link "Your work"
 click_link "Your work"
end

#Upload a new hyperlink
And /^I enter the hyperlink "([^"]*)" for my work$/ do |hyperlink|
   should have_button "Upload link"
   fill_in 'submission', :with => hyperlink
end

#Check the if the new link display in the new page
Then /^I should see that the link "([^"]*)" is present on the page$/ do |hyperlink|
  should have_link hyperlink
end